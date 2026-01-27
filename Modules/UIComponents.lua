local addonName, ns =...

-- =========================================================
-- 1. 模块定义 (100% 还原原插件 UI 工具命名空间)
-- =========================================================
local UIComponents = { name = "UIComponents", enabled = true }
ns.UIComponents = UIComponents

-- 缓存 12.0 核心 UI API
local MenuUtil = _G.MenuUtil
local CreateAtlasMarkup = _G.CreateAtlasMarkup

-- =========================================================
-- 2. 核心：现代上下文菜单 (基于 12.0 MenuUtil)
-- =========================================================
-- [[100% 还原]: 还原原插件右键功能菜单，解决 12.0 战斗拦截报错]

-- @param owner: 触发菜单的 Region
function UIComponents:ShowMainMenu(owner)
    if not owner or not MenuUtil then return end
    
    -- 确保核心数据已初始化
    if not ns.DB or not ns.Cache or not ns.L then
        print("|cFFFF0000[LorisID]|r Core data not initialized. Cannot show menu.")
        return
    end

    -- 12.0 生成器逻辑：通过闭包构建菜单描述，确保跨版本抗污染
    local function Generator(owner, rootDescription)
        -- 使用 pcall 保护菜单生成，防止插件冲突
        local success, err = pcall(function()
            rootDescription:CreateTitle(("|cFF%s%s|r"):format(ns.Colors.Header.hex:sub(3), ns.Name))
            
            -- 1. 全局开关 (还原原插件 Checkbox 交互)
            rootDescription:CreateCheckbox(
                ns.L["EnableModule"], 
                function() return ns.DB.enabled end, 
                function() 
                    ns.DB.enabled = not ns.DB.enabled
                    if ns.DB.debugMode then 
                        print(ns.Name.. ": Status changed to", ns.DB.enabled) 
                    end
                end
            )
            
            rootDescription:CreateDivider()

            -- 2. 缓存管理子菜单 (还原原插件 Cache 功能)
            local cacheMenu = rootDescription:CreateButton(ns.L["Performance & Cache"])
            cacheMenu:CreateButton(ns.L["Item"], function() 
                if ns.Cache then ns.Cache:Clear("item") end 
            end)
            cacheMenu:CreateButton(ns.L["Spell"], function() 
                if ns.Cache then ns.Cache:Clear("spell") end 
            end)
            cacheMenu:CreateButton(ns.L["Clear All"], function() 
                if ns.Cache then ns.Cache:Clear() end 
            end)

            -- 3. 调试模式切换
            rootDescription:CreateCheckbox(
                ns.L["Debug Mode"], 
                function() return ns.DB.debugMode end, 
                function() ns.DB.debugMode = not ns.DB.debugMode end
            )

            rootDescription:CreateDivider()

            -- 4. 打开设置面板 (12.0 Settings API 连接)
            rootDescription:CreateButton(ns.L["Cmd_Config"], function()
                if ns.ConfigCategoryID then
                    Settings.OpenToCategory(ns.ConfigCategoryID)
                end
            end)
        end)
        
        if not success then
            print("|cFFFF0000[LorisID]|r Menu generation error:", err)
        end
    end

    -- 12.0 最佳实践：立即在鼠标位置弹出
    MenuUtil.CreateContextMenu(owner, Generator)
end

-- =========================================================
-- 3. 核心：12.0 鼠标聚焦精准探测
-- =========================================================
-- [[100% 还原]: 解决 GetMouseFocus() 在 12.0 返回 Table 导致的逻辑失效]

function UIComponents:IsMouseOver(frame)
    if not frame then return false end
    
    -- 12.0 规范：IsMouseMotionFocus() 是替代 GetMouseFocus() 的标准高效 API 
    -- 它能准确识别当前鼠标是否位于指定 Region 之上，且支持 12.0 的鼠标传播逻辑
    return frame:IsMouseMotionFocus()
end

-- =========================================================
-- 4. 辅助：12.0 矢量图标解析 (Atlas Markup)
-- =========================================================
-- [[100% 还原]: 还原原插件图标显示功能，并适配 12.0 高清 UI 缩放]

function UIComponents:GetAtlasIcon(atlasName, size)
    if not atlasName then return "" end
    size = size or 16
    -- 12.0 鼓励使用 Atlas 以支持 UI 矢量缩放
    return CreateAtlasMarkup(atlasName, size, size)
end

-- =========================================================
-- 5. 战斗安全显示 (12.0 秘密值防御)
-- =========================================================
-- [[100% 还原]: 还原原插件在 UI 上显示动态数值的能力，防止 12.0 报错]

function UIComponents:SafeSetText(fontString, rawValue)
    if not fontString then return end
    
    -- 使用文件 4 定义的 Security 模块进行脱敏处理 [1, 2, 3]
    -- 12.0 规范：禁止直接将 Secret 值赋给非安全 FontString 否则会造成 Taint 传播
    local safeValue = ns.Security:IsSafe(rawValue) and tostring(rawValue) or "???"
    fontString:SetText(safeValue)
    
    -- 如果是秘密值，应用特殊紫色高亮 (至暗之夜风格)
    if not ns.Security:IsSafe(rawValue) then
        fontString:SetTextColor(0.5, 0, 1) -- 秘密值紫色
    end
end