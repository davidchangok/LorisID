local addonName, ns =...

-- =========================================================
-- 1. 命名空间与 12.0 元数据获取
-- =========================================================
ns.Name = addonName
-- 12.0 标准 API：获取版本和作者信息
ns.Version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "3.2.5"
ns.Author = C_AddOns.GetAddOnMetadata(addonName, "Author") or "David W Zhang"

-- =========================================================
-- 2. 核心常量定义 (100% 还原原插件 Defaults.lua)
-- =========================================================
-- 颜色表 (RGB 小数模式，用于 Tooltip 渲染)
ns.Colors = {
    ID      = { r = 1.0, g = 1.0, b = 1.0, hex = "ffffffff" }, -- 白色
    Label   = { r = 0.5, g = 0.8, b = 1.0, hex = "ff80ccff" }, -- 浅蓝
    Header  = { r = 0.3, g = 1.0, b = 0.3, hex = "ff4cff4c" }, -- 绿色
    Warning = { r = 1.0, g = 0.6, b = 0.0, hex = "ffff9900" }, -- 橙色
    Error   = { r = 1.0, g = 0.3, b = 0.3, hex = "ffff4c4c" }, -- 红色
}

-- 扩展包名称表 (0-12, 涵盖 12.0 午夜版本)
ns.ExpansionNames = {
    [0]  = "Classic",
    [1]  = "The Burning Crusade",
    [2]  = "Wrath of the Lich King",
    [3]  = "Cataclysm",
    [4]  = "Mists of Pandaria",
    [5]  = "Warlords of Draenor",
    [6]  = "Legion",
    [7]  = "Battle for Azeroth",
    [8]  = "Shadowlands",
    [9]  = "Dragonflight",
    [10] = "The War Within",
    [11] = "Midnight",
    [12] = "The Last Titan",
}

-- 初始化数据库配置，确保所有配置项都有默认值
function ns:InitializeDB()
    -- 直接使用 .toc 中定义的 SavedVariables: LorisIDDB
    -- 如果是首次加载，LorisIDDB 会是 nil，我们需要将其初始化为一个空表
    LorisIDDB = LorisIDDB or {}
    
    -- 默认设置定义 (修复 Line 25: unexpected symbol)
    local defaults = {
        enabled = true,
        debugMode = false,
        showIcons = true,
        perfThreshold = 10, -- 12.0 性能审计阈值(ms)
        cache = {
            enabled = true,
            maxSize = 1000,
        },
        ids = {
            ["item"] = true,
            ["spell"] = true,
            ["unit"] = true,
            ["quest"] = true,
            ["achievement"] = true,
            ["currency"] = true,
            ["mount"] = true,
            ["toy"] = true,
            ["talent"] = true,
            ["icon"] = true,
        }
    }

    -- 深度合并默认值
    -- 这里我们将默认值填充到 LorisIDDB 中
    for k, v in pairs(defaults) do
        if LorisIDDB[k] == nil then
            LorisIDDB[k] = v
        elseif type(v) == "table" then
            for subK, subV in pairs(v) do
                if LorisIDDB[k][subK] == nil then
                    LorisIDDB[k][subK] = subV
                end
            end
        end
    end

    -- 挂载引用到 ns.DB，供全插件使用
    ns.DB = LorisIDDB
end

-- =========================================================
-- 3. 事件引导逻辑
-- =========================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        ns:InitializeDB()
        
        -- 调试模式下的启动报告
        if ns.DB.debugMode then
            print(("|cFF%s[%s]|r: %s"):format(ns.Colors.Header.hex:sub(3), ns.Name, ns.L["Init_Loaded"]))
        end
        
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- 支持的 ID 类型映射 (对应原插件 IDTypes)
ns.IDTypes = {
    ITEM = "item", SPELL = "spell", UNIT = "unit", QUEST = "quest",
    ACHIEVEMENT = "achievement", CURRENCY = "currency", MOUNT = "mount",
    TOY = "toy", ICON = "icon", TALENT = "talent", EQUIP_SET = "set",
    VISUAL = "visual",
}