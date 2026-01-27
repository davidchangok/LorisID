local addonName, ns =...

-- =========================================================
-- 1. 12.0 设置系统常量 (100% 还原原插件配置结构)
-- =========================================================
local Settings = _G.Settings
local SettingsLib = _G.SettingsLib
local L = ns.L

--[[100% 还原]: 注册 LorisID 设置面板逻辑]]
local function RegisterAllSettings()
    -- 1. 创建 12.0 垂直布局主分类
    -- 12.0 规范：使用本地化名称，以便在设置搜索框中被找到
    local category = Settings.RegisterVerticalLayoutCategory(ns.Name, L["Settings"])
    -- [修复]: 保存分类 ID 供 Core.lua 调用，Settings.OpenToCategory 需要数字 ID 而非字符串名称
    ns.ConfigCategoryID = category:GetID()

    -- =========================================================
    -- 2. 常规设置 (General Settings)
    -- =========================================================
    -- 12.0 签名: category, settingName, variableKey, variableTbl, varType, displayName, defaultValue
    
    -- 主开关
local enabledSetting = Settings.RegisterAddOnSetting(
    category, 
    "LorisID_Enabled",     -- 设置名
    "enabled",             -- 变量键
    ns.DB,                 -- 表引用 ✓
    "boolean",             -- 变量类型 (直接使用字符串更清晰)
    L["EnableModule"],     -- 显示名称 (本地化元表已处理回退)
    true
)
    Settings.CreateCheckbox(category, enabledSetting, L["Settings_Enable_Desc"])

    -- 调试模式
    local debugSetting = Settings.RegisterAddOnSetting(
        category, "LorisID_Debug", "debugMode", ns.DB, "boolean", L["Debug Mode"], false
    )
    Settings.CreateCheckbox(category, debugSetting, L["Settings_Debug_Desc"])

    -- =========================================================
    -- 3. ID 类型精细化控制 (100% 还原原插件 IDTypes 勾选)
    -- =========================================================
    local idSubCategory = Settings.RegisterVerticalLayoutSubcategory(category, L["ID Display Settings"])
    
    -- 在 12.0 中，我们必须明确指向 ns.DB.ids 子表以符合新版 API 读写规范
    local idTypesToRegister = {
        { key = "item",        label = L["Item"] },
        { key = "spell",       label = L["Spell"] },
        { key = "unit",        label = L["Unit"] },
        { key = "quest",       label = L["Quest"] },
        { key = "achievement", label = L["Achievement"] },
        { key = "currency",    label = L["Currency"] },
        { key = "mount",       label = L["Mount"] },
        { key = "toy",         label = L["Toy"] },
        { key = "talent",      label = L["Talent"] },
        { key = "icon",        label = L["Icon"] },
    }

    for _, cfg in ipairs(idTypesToRegister) do
        local idSetting = Settings.RegisterAddOnSetting(
            idSubCategory, 
            "LorisID_ID_".. cfg.key:gsub("^%l", string.upper), -- e.g., LorisID_ID_Item
            cfg.key, 
            ns.DB.ids, -- 指向子表 
            "boolean", 
            cfg.label, 
            true
        )
        Settings.CreateCheckbox(idSubCategory, idSetting, "")
    end

    -- =========================================================
    -- 4. 缓存与性能控制 (Performance & Cache)
    -- =========================================================
    local perfSubCategory = Settings.RegisterVerticalLayoutSubcategory(category, L["Performance & Cache"])

    -- LRU 缓存开关
    local cacheSetting = Settings.RegisterAddOnSetting(
        perfSubCategory, "LorisID_CacheEnabled", "enabled", ns.DB.cache, "boolean", L["Enable high-performance LRU cache"], true
    )
    Settings.CreateCheckbox(perfSubCategory, cacheSetting, L["Settings_Cache_Desc"])

    -- 缓存容量调节 (Slider)
    local cacheSizeSetting = Settings.RegisterAddOnSetting(
        perfSubCategory, "LorisID_CacheSize", "maxSize", ns.DB.cache, "number", L["Cache Size Limit"], 1000
    )
    local sizeOptions = Settings.CreateSliderOptions(100, 5000, 100)
    sizeOptions:SetLabelFormatter(function(v) return ("%d %s"):format(v, L["Items Count"]) end)
    Settings.CreateSlider(perfSubCategory, cacheSizeSetting, sizeOptions, L["Settings_CacheSize_Desc"])

    -- 12.0 性能预警阈值
    local thresholdSetting = Settings.RegisterAddOnSetting(
        perfSubCategory, "LorisID_PerfThreshold", "perfThreshold", ns.DB, "number", L["Performance Audit Warning Threshold"], 10
    )
    local thresholdOptions = Settings.CreateSliderOptions(1, 100, 1)
    thresholdOptions:SetLabelFormatter(function(v) return ("%d ms"):format(v) end)
    Settings.CreateSlider(perfSubCategory, thresholdSetting, thresholdOptions, L["Settings_Threshold_Desc"])

    -- =========================================================
    -- 5. 提交注册
    -- =========================================================
    Settings.RegisterAddOnCategory(category)
end

-- =========================================================
-- 6. 设置面板初始化挂载
-- =========================================================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN") -- 确保 ns.DB 已在 Init.lua 中完成深度填充
f:SetScript("OnEvent", function(self)
    -- 还原度审计：确认 ns.DB 及其子表 ids 存在
    if ns.DB and ns.DB.ids then
        RegisterAllSettings()
        self:UnregisterEvent("PLAYER_LOGIN")
    else
        -- 容错：如果加载顺序异常，延迟重试
        C_Timer.After(1, function() RegisterAllSettings() end)
    end
end)