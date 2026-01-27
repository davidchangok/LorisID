local addonName, ns =...

-- =========================================================
-- 1. 模块定义 (100% 还原原插件 IDDisplay 核心)
-- =========================================================
local IDDisplay = { name = "IDDisplay", enabled = true }
ns.IDDisplay = IDDisplay

-- 缓存引用，优化 12.0 Profiler 性能
local L = ns.L
local Colors = ns.Colors
local IDTypes = ns.IDTypes
local Security = ns.Security

-- 12.0 核心命名空间
local TooltipDataProcessor = _G["TooltipDataProcessor"]
local Enum = _G.Enum
local C_Item = _G.C_Item
local C_Spell = _G.C_Spell

-- 12.0 结构化映射表 (修复：补全枚举索引，解决 unexpected symbol 错误) 
local TooltipDataTypeMap = {
    [Enum.TooltipDataType.Item]        = IDTypes.ITEM,
    [Enum.TooltipDataType.Toy]         = IDTypes.ITEM,
    [Enum.TooltipDataType.Spell]       = IDTypes.SPELL,
    [Enum.TooltipDataType.UnitAura]    = IDTypes.SPELL,
    [Enum.TooltipDataType.Unit]        = IDTypes.UNIT,
    [Enum.TooltipDataType.Quest]       = IDTypes.QUEST,
    [Enum.TooltipDataType.Achievement] = IDTypes.ACHIEVEMENT,
    [Enum.TooltipDataType.Currency]    = IDTypes.CURRENCY,
    [Enum.TooltipDataType.Mount]       = IDTypes.MOUNT,
    [Enum.TooltipDataType.EquipmentSet]= IDTypes.EQUIP_SET,
}

-- =========================================================
-- 2. 核心逻辑：注入与查重 (100% 还原)
-- =========================================================

-- [[100% 还原]: 查重算法，防止 12.0 数据更新时行数翻倍]
function IDDisplay:HasLine(tooltip, text)
    if not tooltip or not text then return false end
    
    -- [修复]: 弃用 _G[name.."TextLeft"..i] 旧架构，改用 Region 迭代
    -- 这是 12.0 兼容性最强的方法，支持所有类型的 Tooltip 框架
    for _, region in ipairs({tooltip:GetRegions()}) do
        if region and region:IsObjectType("FontString") then
            local lineText = region:GetText()
            if lineText and Security:IsSafe(lineText) and lineText == text then
                return true
            end
        end
    end
    return false
end

-- [[100% 还原]: 注入物理行，带 12.0 安全审计与 MBB 冲突修复]
function IDDisplay:AddLine(tooltip, id, idType)
    if not tooltip or not id or not idType then return end
    
    -- 权限检查
    if not ns.DB.ids then return end

    -- 本地化标签解析
    -- 修正：使用 TitleCase (如 "Spell ID") 以匹配 Localization.lua 中的定义
    -- 解决中文环境下显示 "SPELL ID" 的问题
    local label = L[idType:gsub("^%l", string.upper).. " ID"]
    
    -- 执行查重
    if self:HasLine(tooltip, label..":") then return end

    -- 12.0 安全格式化：若处于战斗限制则显示脱敏占位符 
    local displayID = Security:Format(id)

    -- 冲突防御：使用 pcall 包装渲染过程，解决 MBB 重定父级引发的崩溃
    pcall(function()
        -- 移除强制空行，解决 ID 之间出现多余间距的问题
        tooltip:AddDoubleLine(
            ("|cFF%s%s:|r"):format(Colors.Label.hex:sub(3), label),
            ("|cFF%s%s|r"):format(Colors.ID.hex:sub(3), displayID)
        )
    end)
end

-- =========================================================
-- 3. 递归探测：100% 还原多维 ID 映射
-- =========================================================

function IDDisplay:AddRelatedIDs(tooltip, mainID, mainType)
    if not ns.DB.showIcons then return end

    if mainType == IDTypes.ITEM then
        -- 探测图标 (C_Item 返回第 10 位) 
        local info = { C_Item.GetItemInfo(mainID) }
        if info[10] then self:AddLine(tooltip, info[10], IDTypes.ICON) end
        
        -- 探测物品关联技能
        local _, spellID = C_Item.GetItemSpell(mainID)
        if spellID then self:AddLine(tooltip, spellID, IDTypes.SPELL) end
        
    elseif mainType == IDTypes.SPELL then
        -- 12.0 规范：从结构化 Table 提取图标 
        local spellInfo = C_Spell.GetSpellInfo(mainID)
        if spellInfo and spellInfo.iconID then
            self:AddLine(tooltip, spellInfo.iconID, IDTypes.ICON)
        end
    end
end

-- [[100% 还原]: GUID 解析算法]
function IDDisplay:GetUnitID(guid)
    if not guid or guid:find("Player") then return nil end
    return guid:match("-(%d+)-%x+$")
end

-- =========================================================
-- 4. 12.0 处理核心 (MBB 冲突防御层)
-- =========================================================

function IDDisplay:ProcessTooltipData(tooltip, data)
    -- 1. 安全拦截：主开关、数据有效性检查 
    if not tooltip or not data or not ns.DB.enabled then return end
    
    -- [新增] 严格表级安全检查：防止 data 本身是受保护的 Table，访问其字段会导致崩溃
    if not Security:IsSafe(data) then return end

    -- 2. 12.0 秘密值墙：若 ID 本身被系统拦截（如 MBB 按钮），立即跳过防止 UI 闪烁
    if issecretvalue and issecretvalue(data.id) then return end

    local idType = TooltipDataTypeMap[data.type]
    local mainID = data.id

    -- 3. 单位特殊解析 (使用 Security:SafeGet 保护 GUID 解析)
    if data.type == Enum.TooltipDataType.Unit then
        mainID = Security:SafeGet(self.GetUnitID, self, data.guid)
    end

    if mainID then
        -- 4. 注入逻辑
        self:AddLine(tooltip, mainID, idType or IDTypes.UNIT)
        self:AddRelatedIDs(tooltip, mainID, idType)
    end
end

-- =========================================================
-- 5. 生命周期初始化
-- =========================================================
function IDDisplay:Init()
    if not TooltipDataProcessor then return end

    -- 使用 12.0 统一 PostCall 钩子 
    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
        self:ProcessTooltipData(tooltip, data)
    end)
end

IDDisplay:Init()