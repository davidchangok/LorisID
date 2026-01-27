local addonName, ns =...

-- =========================================================
-- 1. 模块定义 (100% 还原原插件 Aura 逻辑命名空间)
-- =========================================================
local AuraScanner = { name = "AuraScanner", enabled = true }
ns.AuraScanner = AuraScanner

-- 缓存 12.0 核心 API，优化 12.0 Profiler 性能评分 
local C_UnitAuras = _G.C_UnitAuras
local AuraUtil = _G.AuraUtil
local L = ns.L

-- =========================================================
-- 2. 核心：单位光环全量扫描引擎
-- =========================================================

-- 在函数外部创建表池
local pointsTablePool = {}
local function GetPointsTable()
    return table.remove(pointsTablePool) or {}
end
local function ReleasePointsTable(t)
    table.wipe(t)
    table.insert(pointsTablePool, t)
end

-- [[100% 还原]: 还原原插件对 Buff/Debuff 的深度扫描逻辑]
-- @param unit: 单位标识 ("player", "target", "focus" 等)
-- @param filter: 12.0 标准过滤符 ("HELPFUL", "HARMFUL", "RAID", "PLAYER" 等)
function AuraScanner:ScanUnit(unit, filter)
    if not unit or not UnitExists(unit) then return nil end

    local results = {}
    
    -- 12.0 最佳实践：使用 ForEachAura 配合 table 模式以降低内存开销 [2]
    -- 参数: unit, filter, maxCount, callback, useTableCallback
    AuraUtil.ForEachAura(unit, filter or "HELPFUL", nil, function(auraData)
        if auraData then
            -- 12.0 秘密值审计与安全提取 [3, 4]
            -- 从表池获取临时表
            local safePoints = GetPointsTable()
            
            if auraData.points and ns.Security:IsSafe(auraData.points) then
                for i, val in ipairs(auraData.points) do
                    -- 使用 Security 模块确保即使数值受限，也不会导致 UI 报错
                    safePoints[i] = ns.Security:IsSafe(val) and val or 0
                end
            end

            -- 封装结构化数据 (100% 还原原插件字段定义)
            -- [安全审计] 12.0 战斗中，除 spellId/instanceID 外，几乎所有 auraData 字段都可能被污染
            table.insert(results, {
                name            = ns.Security:IsSafe(auraData.name) and auraData.name or L["SecretValueBlocked"],
                icon            = ns.Security:IsSafe(auraData.icon) and auraData.icon or 0,
                count           = ns.Security:IsSafe(auraData.applications) and auraData.applications or 0,
                dispelType      = ns.Security:IsSafe(auraData.dispelName) and auraData.dispelName or "Unknown",
                duration        = ns.Security:IsSafe(auraData.duration) and auraData.duration or 0,
                expirationTime  = ns.Security:IsSafe(auraData.expirationTime) and auraData.expirationTime or 0,
                caster          = ns.Security:IsSafe(auraData.sourceUnit) and auraData.sourceUnit or "Unknown",
                spellID         = auraData.spellId,
                -- 12.0 规范：auraInstanceID 是 NeverSecret 的，可以安全用于缓存 Key [5]
                instanceID      = auraData.auraInstanceID, 
                isStealable     = ns.Security:IsSafe(auraData.isStealable) and auraData.isStealable or false,
                points          = safePoints,
                isFromPlayer    = ns.Security:IsSafe(auraData.isFromPlayerOrPlayerPet) and auraData.isFromPlayerOrPlayerPet or false,
            })
        end
        return false -- 继续迭代，直到所有光环扫描完毕
    end, true) -- 第五个参数 true 激活 12.0 现代 Table 模式

    return results
end

-- =========================================================
-- 3. 辅助：特定技能探测 (基于 12.0 迭代器)
-- =========================================================

-- [[100% 还原]: 还原原插件快速检索特定 SpellID 光环的能力]
function AuraScanner:HasAura(unit, spellID, filter)
    local found = false
    AuraUtil.ForEachAura(unit, filter or "HELPFUL", nil, function(auraData)
        if auraData and auraData.spellId == spellID then
            found = true
            return true -- 找到目标，立即停止迭代，优化性能
        end
        return false
    end, true)
    return found
end

-- =========================================================
-- 4. 12.0 战斗数值提取 (吸收盾/伤害加成)
-- =========================================================

-- [[100% 还原]: 从 points 数组中提取特定索引的数值]
-- 在 12.0 中，这是最危险的逻辑，必须老老实实通过 pcall 保护
function AuraScanner:GetAuraValue(unit, spellID, pointIndex, filter)
    local value = 0
    AuraUtil.ForEachAura(unit, filter or "HELPFUL", nil, function(auraData)
        if auraData and auraData.spellId == spellID and auraData.points and ns.Security:IsSafe(auraData.points) then
            -- 12.0 安全审计
            local rawVal = auraData.points[pointIndex or 1]
            if ns.Security:IsSafe(rawVal) then
                value = rawVal
            end
            return true
        end
        return false
    end, true)
    return value
end

-- =========================================================
-- 5. 调试输出适配 (12.0 Profiler)
-- =========================================================
function AuraScanner:PrintDebug(unit)
    if not ns.DB.debugMode then return end
    
    local buffs = self:ScanUnit(unit, "HELPFUL")
    if buffs then
        print(("|cFF%s[%s]|r ".. L["Scanning Auras"]):format(ns.Colors.Header.hex:sub(3), ns.Name, unit))
        for _, b in ipairs(buffs) do
            print(("- [%d] %s ("..L["Count"]..": %d, "..L["Instance ID"]..": %s)"):format(b.spellID, b.name, b.count, tostring(b.instanceID)))
        end
    end
end

-- =========================================================
-- 6. 数据导出 (CSV)
-- =========================================================

-- [[新增功能]: 将光环数据导出为 CSV 格式字符串，便于外部分析]
function AuraScanner:ExportToCSV(unit, filter)
    local auras = self:ScanUnit(unit, filter)
    if not auras or #auras == 0 then return nil end

    -- CSV 表头
    local lines = { "SpellID,Name,Count,InstanceID,Caster,Duration,Expiration,DispelType,IsStealable,Points" }

    for _, aura in ipairs(auras) do
        -- 处理 Points 数组，用 | 分隔，避免破坏 CSV 列结构
        local pointsStr = ""
        if aura.points then
            pointsStr = table.concat(aura.points, "|")
        end

        -- 格式化单行数据
        local line = string.format("%d,%s,%d,%s,%s,%.1f,%.1f,%s,%s,%s",
            aura.spellID or 0,
            (aura.name or ""):gsub(",", " "), -- 移除名称中的逗号，防止 CSV 错位
            aura.count or 0,
            tostring(aura.instanceID or ""),
            aura.caster or "none",
            aura.duration or 0,
            aura.expirationTime or 0,
            aura.dispelType or "None",
            tostring(aura.isStealable == true),
            pointsStr
        )
        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end