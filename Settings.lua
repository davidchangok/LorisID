local addonName, ns =...

-- =========================================================
-- 1. 12.0 设置系统常量
-- =========================================================
local Settings = _G.Settings
local L = ns.L

-- =========================================================
-- 2. UI 构建基础 (PhaseWatcher 参考模式)
-- =========================================================

-- 创建带有边框和标题的 GroupBox
local function CreateGroupBox(category, title, height)
    local frame = CreateFrame("Frame", nil, category, "BackdropTemplate")
    frame:SetSize(600, height)
    
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

-- 创建 CheckButton (直接读写 ns.DB，无需 RegisterAddOnSetting)
local function CreateCheckButton(parent, label, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)
    
    cb:SetChecked(getFunc())
    
    cb:SetScript("OnClick", function(self)
        setFunc(self:GetChecked())
    end)
    
    return cb
end

-- 创建 Slider (直接读写 ns.DB，无需 RegisterAddOnSetting)
local function CreateSliderControl(parent, label, options, getFunc, setFunc)
    local slider = CreateFrame("Slider", nil, parent, "UISliderTemplate")
    slider:SetWidth(200)
    slider:SetHeight(17)
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

    local currentValue = getFunc()
    slider:SetValue(currentValue)
    UpdateValueText(currentValue)

    slider:SetScript("OnValueChanged", function(self, value)
        if getFunc() ~= value then
            setFunc(value)
        end
        UpdateValueText(value)
    end)
    
    return slider
end

-- =========================================================
-- 3. 面板组装 (PhaseWatcher 模式: 先建内容，最后注册)
-- =========================================================

local function CreateSettingsPanel()
    if not ns.DB or not ns.DB.ids or not ns.DB.cache then
        print("|cFFFF0000[LorisID]|r Settings: Database not initialized!")
        return
    end

    -- 1. 创建面板 (PhaseWatcher: UIParent + panel.name)
    local categoryName = "|TInterface\\AddOns\\LorisID\\icon:16|t " .. L["AddonName"]
    local panel = CreateFrame("Frame", "LorisID_SettingsPanel", UIParent)
    panel.name = categoryName

    -- 2. 创建 ScrollFrame + scrollChild (PhaseWatcher: UIPanelScrollFrameTemplate)
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(610, 520)
    scrollFrame:SetScrollChild(content)

    -- 3. 构建所有 UI 内容 (挂载到 scrollChild content 上)
    local yOffset = 0

    -- GroupBox 1: Control
    local groupControl = CreateGroupBox(content, L["Control"], 80)
    groupControl:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    yOffset = yOffset - 90

    local cbEnable = CreateCheckButton(groupControl, L["EnableModule"],
        function() return ns.DB.enabled end,
        function(v) ns.DB.enabled = v end
    )
    cbEnable:SetPoint("TOPLEFT", 15, -20)

    local cbDebug = CreateCheckButton(groupControl, L["Debug Mode"],
        function() return ns.DB.debugMode end,
        function(v) ns.DB.debugMode = v end
    )
    cbDebug:SetPoint("TOPLEFT", 15, -50)

    -- GroupBox 2: ID Display Settings - 三列布局
    local groupID = CreateGroupBox(content, L["ID Display Settings"], 240)
    groupID:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    yOffset = yOffset - 250

    local col1 = { "item", "spell", "unit", "quest", "achievement", "set", "pvp" }
    for i, key in ipairs(col1) do
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local cb = CreateCheckButton(groupID, L[labelKey],
            function() return ns.DB.ids[key] end,
            function(v) ns.DB.ids[key] = v end
        )
        cb:SetPoint("TOPLEFT", 15, -20 - (i-1)*30)
    end

    local col2 = { "currency", "mount", "toy", "talent", "icon", "visual", "minimap" }
    for i, key in ipairs(col2) do
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local cb = CreateCheckButton(groupID, L[labelKey],
            function() return ns.DB.ids[key] end,
            function(v) ns.DB.ids[key] = v end
        )
        cb:SetPoint("TOPLEFT", 210, -20 - (i-1)*30)
    end

    local col3 = { "companion", "object", "battlepet", "instance", "recipe", "macro" }
    for i, key in ipairs(col3) do
        local labelKey = key:sub(1,1):upper() .. key:sub(2)
        local cb = CreateCheckButton(groupID, L[labelKey],
            function() return ns.DB.ids[key] end,
            function(v) ns.DB.ids[key] = v end
        )
        cb:SetPoint("TOPLEFT", 405, -20 - (i-1)*30)
    end

    -- GroupBox 3: Performance & Cache
    local groupPerf = CreateGroupBox(content, L["Performance & Cache"], 160)
    groupPerf:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)

    local cbCache = CreateCheckButton(groupPerf, L["Enable high-performance LRU cache"],
        function() return ns.DB.cache.enabled end,
        function(v) ns.DB.cache.enabled = v end
    )
    cbCache:SetPoint("TOPLEFT", 15, -20)

    local optsSize = {
        minValue = 100,
        maxValue = 5000,
        steps = {100},
        formatter = function(v) return ("%d %s"):format(v, L["Items Count"]) end
    }
    local sliderSize = CreateSliderControl(groupPerf, L["Cache Size Limit"], optsSize,
        function() return ns.DB.cache.maxSize end,
        function(v) ns.DB.cache.maxSize = v end
    )
    sliderSize:SetPoint("TOPLEFT", 15, -70)

    local optsPerf = {
        minValue = 1,
        maxValue = 100,
        steps = {1},
        formatter = function(v) return ("%d ms"):format(v) end
    }
    local sliderPerf = CreateSliderControl(groupPerf, L["Performance Audit Warning Threshold"], optsPerf,
        function() return ns.DB.perfThreshold end,
        function(v) ns.DB.perfThreshold = v end
    )
    sliderPerf:SetPoint("TOPLEFT", 250, -70)

    -- 4. 最后注册 (PhaseWatcher 模式: 全部内容构建完毕后注册)
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    ns.ConfigCategoryID = category:GetID()
    Settings.RegisterAddOnCategory(category)
end

-- =========================================================
-- 4. 设置面板初始化挂载
-- =========================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        local success, err = pcall(function()
            if ns.DB and ns.DB.ids and ns.DB.cache then
                CreateSettingsPanel()
            else
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
        
        self:UnregisterEvent("ADDON_LOADED")
    end
end)