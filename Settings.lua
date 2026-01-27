local addonName, ns =...

-- =========================================================
-- 1. 12.0 设置系统常量 (100% 还原原插件配置结构)
-- =========================================================
local Settings = _G.Settings
local L = ns.L

-- =========================================================
-- 2. UI 构建基础 (Canvas 模式 - 仿 Plumber 架构)
-- =========================================================

-- 创建带有边框和标题的 GroupBox
local function CreateGroupBox(category, title, height)
    local frame = CreateFrame("Frame", nil, category, "BackdropTemplate")
    frame:SetSize(600, height) -- 宽度适配设置面板
    
    frame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
    
    local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", 15, 6)
    fs:SetText(" " .. title .. " ")
    
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0.1, 0.1, 0.1, 1)
    bg:SetPoint("TOPLEFT", fs, -2, 0)
    bg:SetPoint("BOTTOMRIGHT", fs, 2, 0)
    
    return frame
end

-- 在 GroupBox 内部创建 Checkbox 并绑定 Setting
local function CreateCheckButton(parent, setting, label)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)
    
    -- 初始化状态
    cb:SetChecked(setting:GetValue())
    
    -- 用户点击时更新设置
    cb:SetScript("OnClick", function(self)
        setting:SetValue(self:GetChecked())
    end)
    
    -- 12.0 修复：使用正确的回调注册方式
    -- Setting 对象本身就是 Variable，不需要调用 GetVariable()
    if setting.RegisterCallback then
        setting:RegisterCallback(SettingsLib.OnValueChangedCallback, function(_, settingObj, value)
            cb:SetChecked(value)
        end, cb)
    end
    
    return cb
end

-- 在 GroupBox 内部创建 Slider 并绑定 Setting
local function CreateSliderControl(parent, setting, label, options)
    local slider = CreateFrame("Slider", nil, parent, "UISliderTemplate")
    slider:SetWidth(200)
    slider:SetHeight(17) -- 标准高度
    slider:SetMinMaxValues(options.minValue, options.maxValue)
    slider:SetValueStep(options.steps[1])
    slider:SetObeyStepOnDrag(true)
    
    slider.text = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    slider.text:SetPoint("BOTTOM", slider, "TOP", 0, 4)
    slider.text:SetText(label)

    slider.low = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    slider.low:SetText(options.minValue)

    slider.high = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
    slider.high:SetText(options.maxValue)
    
    local function UpdateValueText(val)
        if options.formatter then
            slider.text:SetText(label .. ": " .. options.formatter(val))
        end
    end

    -- 初始化值
    slider:SetValue(setting:GetValue())
    UpdateValueText(setting:GetValue())

    -- 用户拖动时更新设置
    slider:SetScript("OnValueChanged", function(self, value)
        if setting:GetValue() ~= value then
            setting:SetValue(value)
        end
        UpdateValueText(value)
    end)

    -- 12.0 修复：使用正确的回调注册方式
    if setting.RegisterCallback then
        setting:RegisterCallback(SettingsLib.OnValueChangedCallback, function(_, settingObj, value)
            if slider:GetValue() ~= value then
                slider:SetValue(value)
            end
            UpdateValueText(value)
        end, slider)
    end
    
    return slider
end

-- =========================================================
-- 3. 面板组装 (Canvas Layout)
-- =========================================================

local function CreateSettingsPanel()
    -- 确保依赖项已加载
    if not ns.DB or not ns.DB.ids or not ns.DB.cache then
        print("|cFFFF0000[LorisID]|r Settings: Database not initialized!")
        return
    end
    
    local panel = CreateFrame("Frame", "LorisID_SettingsPanel")
    
    -- 滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(600, 600) -- 高度需足够容纳内容
    scrollFrame:SetScrollChild(scrollChild)
    
    -- 注册类别 (Settings API)
    local categoryName = "|TInterface\\AddOns\\LorisID\\icon:16|t " .. L["AddonName"]
    local category = Settings.RegisterCanvasLayoutCategory(panel, categoryName)
    ns.ConfigCategoryID = category:GetID()
    
    -- 注册 Setting 对象 (用于 Defaults 逻辑)
    local settingEnabled = Settings.RegisterAddOnSetting(category, "LorisID_Enabled", "enabled", ns.DB, "boolean", L["EnableModule"], true)
    local settingDebug = Settings.RegisterAddOnSetting(category, "LorisID_Debug", "debugMode", ns.DB, "boolean", L["Debug Mode"], false)
    
    local idSettings = {}
    local idKeys = { "item", "spell", "unit", "quest", "achievement", "currency", "mount", "toy", "talent", "icon" }
    for _, key in ipairs(idKeys) do
        -- 12.0 修复：首字母大写以匹配 Localization.lua 中的键名
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local label = L[labelKey] or key
        idSettings[key] = Settings.RegisterAddOnSetting(category, "LorisID_ID_"..key, key, ns.DB.ids, "boolean", label, true)
    end
    
    local settingCache = Settings.RegisterAddOnSetting(category, "LorisID_CacheEnabled", "enabled", ns.DB.cache, "boolean", L["Enable high-performance LRU cache"], true)
    local settingCacheSize = Settings.RegisterAddOnSetting(category, "LorisID_CacheSize", "maxSize", ns.DB.cache, "number", L["Cache Size Limit"], 1000)
    local settingPerf = Settings.RegisterAddOnSetting(category, "LorisID_PerfThreshold", "perfThreshold", ns.DB, "number", L["Performance Audit Warning Threshold"], 10)
    
    Settings.RegisterAddOnCategory(category)
    
    -- 布局内容
    local yOffset = -10
    
    -- GroupBox 1: Control (控制)
    local groupControl = CreateGroupBox(scrollChild, L["Control"], 80)
    groupControl:SetPoint("TOPLEFT", 10, yOffset)
    yOffset = yOffset - 90
    
    local cbEnable = CreateCheckButton(groupControl, settingEnabled, L["EnableModule"])
    cbEnable:SetPoint("TOPLEFT", 15, -20)
    
    local cbDebug = CreateCheckButton(groupControl, settingDebug, L["Debug Mode"])
    cbDebug:SetPoint("TOPLEFT", 15, -50)
    
    -- GroupBox 2: ID Display Settings (ID 显示设置) - 双列布局
    local groupID = CreateGroupBox(scrollChild, L["ID Display Settings"], 180)
    groupID:SetPoint("TOPLEFT", 10, yOffset)
    yOffset = yOffset - 190
    
    local col1 = { "item", "spell", "unit", "quest", "achievement" }
    for i, key in ipairs(col1) do
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local cb = CreateCheckButton(groupID, idSettings[key], L[labelKey])
        cb:SetPoint("TOPLEFT", 15, -20 - (i-1)*30)
    end
    
    local col2 = { "currency", "mount", "toy", "talent", "icon" }
    for i, key in ipairs(col2) do
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local cb = CreateCheckButton(groupID, idSettings[key], L[labelKey])
        cb:SetPoint("TOPLEFT", 200, -20 - (i-1)*30)
    end
    
    -- GroupBox 3: Performance & Cache (性能与缓存)
    local groupPerf = CreateGroupBox(scrollChild, L["Performance & Cache"], 160)
    groupPerf:SetPoint("TOPLEFT", 10, yOffset)
    
    local cbCache = CreateCheckButton(groupPerf, settingCache, L["Enable high-performance LRU cache"])
    cbCache:SetPoint("TOPLEFT", 15, -20)
    
    local optsSize = { 
        minValue = 100, 
        maxValue = 5000, 
        steps = {100}, 
        formatter = function(v) return ("%d %s"):format(v, L["Items Count"]) end 
    }
    local sliderSize = CreateSliderControl(groupPerf, settingCacheSize, L["Cache Size Limit"], optsSize)
    sliderSize:SetPoint("TOPLEFT", 15, -70)
    
    local optsPerf = { 
        minValue = 1, 
        maxValue = 100, 
        steps = {1}, 
        formatter = function(v) return ("%d ms"):format(v) end 
    }
    local sliderPerf = CreateSliderControl(groupPerf, settingPerf, L["Performance Audit Warning Threshold"], optsPerf)
    sliderPerf:SetPoint("TOPLEFT", 250, -70)
end

-- =========================================================
-- 4. 设置面板初始化挂载
-- =========================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN") -- 确保 ns.DB 已在 Init.lua 中完成深度填充
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- 使用 pcall 保护设置面板创建过程
        local success, err = pcall(function()
            -- 确认 ns.DB 及其子表 ids 存在
            if ns.DB and ns.DB.ids and ns.DB.cache then
                CreateSettingsPanel()
            else
                -- 容错：如果加载顺序异常，延迟重试
                C_Timer.After(1, function() 
                    if ns.DB and ns.DB.ids and ns.DB.cache then
                        CreateSettingsPanel()
                    else
                        print("|cFFFF0000[LorisID]|r Failed to initialize settings: Database structure missing")
                    end
                end)
            end
        end)
        
        if not success then
            print("|cFFFF0000[LorisID]|r Settings panel creation failed:", err)
        end
        
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
