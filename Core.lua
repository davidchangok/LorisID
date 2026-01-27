local addonName, ns =...

-- =========================================================
-- 1. 核心控制对象定义 (100% 还原原插件 Core 逻辑)
-- =========================================================
local Core = CreateFrame("Frame", addonName.. "CoreFrame")
ns.Core = Core

-- 缓存引用，优化 12.0 高频事件下的 Profiler 评分
local L = ns.L
local DB = ns.DB
local Security = ns.Security

-- [[新增功能]: 12.0 性能分析器接口]
-- @return number: 返回插件在上一帧的 CPU 耗时 (ms)
function ns:GetAddOnCPUUsage()
    -- 12.0 规范：使用 C_AddOns.GetAddOnCPUUsage 获取精确耗时
    return C_AddOns.GetAddOnCPUUsage(ns.Name)
end

-- =========================================================
-- 2. 命令行系统 (Slash Commands)
-- =========================================================
-- [[100% 还原]: 还原原插件全部命令参数，支持 /et 和 /lorisid]

SLASH_LORISID1 = "/et"
SLASH_LORISID2 = "/lorisid"
SLASH_LORISID3 = "/lid"

SlashCmdList["LORISID"] = function(msg) 
    local cmd, arg = strsplit(" ", msg:lower())
    
    if cmd == "config" or cmd == "settings" or msg == "" then
        -- 12.0 标准：打开设置面板 (修复：必须传入数字 ID)
        if ns.ConfigCategoryID then
            Settings.OpenToCategory(ns.ConfigCategoryID)
        end
        
    elseif cmd == "cache" then
        -- 调用文件 5 定义的 LRU 清理逻辑
        ns.Cache:Clear(arg)
        print(("|cFF%s[%s]|r: %s"):format(ns.Colors.Header.hex:sub(3), ns.Name, L["Cmd_Cache"]))
        
    elseif cmd == "debug" then
        -- 切换 12.0 性能审计模式
        ns.DB.debugMode = not ns.DB.debugMode
        print(("|cFF%s[%s]|r: %s -> %s"):format(
            ns.Colors.Header.hex:sub(3), ns.Name, L["Toggle Debug Mode"], tostring(ns.DB.debugMode)
        ))
        
    elseif cmd == "version" then
        -- 显示版本与作者信息 (还原作者署名)
        print(("|cFF%s[%s]|r v%s by %s"):format(
            ns.Colors.Header.hex:sub(3), ns.Name, ns.Version, ns.Author
        ))
        
    else
        -- 显示命令帮助
        print(("|cFF%s%s|r %s:"):format(ns.Colors.Label.hex:sub(3), ns.Name, L["Cmd_Help"]))
        print("  /lid config - ".. L["Cmd_Config"])
        print("  /lid cache [type] - ".. L["Cmd_Cache"])
        print("  /lid debug - ".. L["Toggle Debug Mode"])
        print("  /lid version - ".. L["Cmd_Version"])
    end
end

-- =========================================================
-- 3. 12.0 战斗限制管理 (Combat Safety)
-- =========================================================
-- [[100% 还原]: 还原原插件战斗检测，并针对 12.0 秘密值系统增强]

function Core:HandleCombatState(inCombat)
    if inCombat then
        -- 12.0 战斗锁定状态提示 [3, 4]
        if ns.DB.debugMode then
            print(("|cFF%s[%s]|r: %s"):format(ns.Colors.Warning.hex:sub(3), ns.Name, L["RestrictedEnvironment"]))
        end
    else
        -- 离开战斗，恢复全量 ID 探测权限
        if ns.DB.debugMode then
            print(("|cFF%s[%s]|r: %s"):format(ns.Colors.Header.hex:sub(3), ns.Name, L["Combat Ended"]))
        end
    end
end

-- =========================================================
-- 4. 事件监听与初始化闭环
-- =========================================================

Core:RegisterEvent("PLAYER_LOGIN")
Core:RegisterEvent("PLAYER_REGEN_DISABLED") -- 进入战斗
Core:RegisterEvent("PLAYER_REGEN_ENABLED")  -- 离开战斗
-- 12.0 异步数据反馈事件 [5, 6]
Core:RegisterEvent("ITEM_DATA_LOAD_RESULT") 
Core:RegisterEvent("QUEST_DATA_LOAD_RESULT")

Core:SetScript("OnEvent", function(self, event,...)
    if event == "PLAYER_LOGIN" then
        -- 启动日志 (数据库已在 ADDON_LOADED 事件中初始化)
        if ns.DB and ns.DB.debugMode then
            print(("|cFF%s[%s]|r: %s"):format(ns.Colors.Header.hex:sub(3), ns.Name, L["Engine Started"]))
        end
        
        -- 启动 12.0 实时性能监控
        C_Timer.NewTicker(5, function()
            if ns.DB and ns.DB.debugMode then
                local cpu = ns:GetAddOnCPUUsage()
                if cpu and cpu > (ns.DB.perfThreshold or 10) then
                    print(("|cFF%s[%s]|r %s (%.2fms)"):format(
                        ns.Colors.Error.hex:sub(3), ns.Name, L["PerfAlert"], cpu
                    ))
                end
            end
        end)

    elseif event == "PLAYER_REGEN_DISABLED" then
        self:HandleCombatState(true)
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:HandleCombatState(false)
        
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        -- 处理来自 12.0 AsyncLoader 的延迟回调
        local itemID, success =...
        if success and ns.Cache then
            -- 强制更新 LRU 缓存时间戳
            ns.Cache:Get("item", itemID)
        end
    end
end)