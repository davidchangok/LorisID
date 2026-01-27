local addonName, ns =...

-- =========================================================
-- 1. 创建本地化元表 (12.0 鲁棒性增强)
-- =========================================================
-- 如果查找的键不存在，则返回键名本身，防止代码运行到一半因 nil 报错
local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end
})

ns.L = L

local locale = GetLocale()

-- =========================================================
-- 2. 默认语言: 英文 (enUS / enGB)
-- =========================================================
-- [修复点]: 严禁 L = "String" 赋值。必须使用索引。
L["AddonName"] = "LorisID |cFF00FF00[Midnight]|r"
L["Init_Loaded"] = "LorisID initialized. Midnight 12.0 API ready."
L["Settings"] = "|cff00ff00Loris|r|cffffd700ID|r Settings"

-- 设置面板 (Settings Panel)
L["Control"] = "Control"
L["EnableModule"] = "Enable Module"
L["Debug Mode"] = "Debug Mode"
L["ID Display Settings"] = "ID Display Settings"
L["Item"] = "Item"
L["Spell"] = "Spell"
L["Unit"] = "Unit"
L["Quest"] = "Quest"
L["Achievement"] = "Achievement"
L["Currency"] = "Currency"
L["Mount"] = "Mount"
L["Toy"] = "Toy"
L["Talent"] = "Talent"
L["Icon"] = "Icon"
L["Performance & Cache"] = "Performance & Cache"
L["Enable high-performance LRU cache"] = "Enable high-performance LRU cache"
L["Cache Size Limit"] = "Cache Size Limit"
L["Performance Audit Warning Threshold"] = "Performance Audit Warning Threshold"

-- 核心 ID 类型 (100% 还原原插件 IDTypes)
L["Spell ID"] = "Spell ID"
L["Item ID"] = "Item ID"
L["Unit ID"] = "Unit ID" -- 补充缺失的键
L["NPC ID"] = "NPC ID"
L["Quest ID"] = "Quest ID"
L["Achievement ID"] = "Achievement ID"
L["Currency ID"] = "Currency ID"
L["Mount ID"] = "Mount ID"
L["Toy ID"] = "Toy ID"
L["Icon ID"] = "Icon ID"
L["Talent ID"] = "Talent ID"
L["Set ID"] = "Equipment Set ID" -- 对应 IDTypes.EQUIP_SET = "set"
L["Equipment Set ID"] = "Equipment Set ID"
L["Visual ID"] = "Visual ID"

-- 分项与详细信息 (100% 还原 IDDisplay 逻辑)
L["Item_Level"] = "Item Level"
L["Stack_Size"] = "Stack Size"
L["Item_Price"] = "Sell Price"
L["Unit_Classification"] = "Classification"
L["GUID"] = "GUID"
L["Target of"] = "Target of"
L["Expansion"] = "Expansion"
L["Count"] = "Count"
L["Instance ID"] = "Instance ID"
-- 12.0 秘密值与安全警告 (12.0 Midnight 专属) [1]
L["SecretValueBlocked"] = "Action Blocked: Logic attempted to operate on a Secret Value during combat."
L["RestrictedEnvironment"] = "Restricted Environment (Mythic+/PvP/Combat). Some UI elements are locked."
L["PerfAlert"] = "Performance Alert: execution time exceeds threshold!"

-- 命令行辅助 (还原原插件功能)
L["Cmd_Config"] = "open settings panel"
L["Cmd_Cache"] = "clear data cache"
L["Cmd_Version"] = "display version info"
L["Cmd_Help"] = "Command Line Help"
L["Clear All"] = "Clear All"
L["Toggle Debug Mode"] = "Toggle Debug Mode"
L["Combat Ended"] = "Combat ended, security audit mode downgraded."
L["Engine Started"] = "12.0 Midnight Core Engine Started."
L["Audit Report"] = "Item Audit Report"
L["Scanning Auras"] = "Scanning 12.0 Aura Data for unit %s..."
L["Settings_Enable_Desc"] = "Enable or disable all LorisID tooltips"
L["Settings_Debug_Desc"] = "Enable 12.0 C_AddOnProfiler audit output"
L["Settings_Cache_Desc"] = "Significantly reduce lag in cities or large scale combat"
L["Settings_CacheSize_Desc"] = "LRU eviction triggers above this count"
L["Settings_Threshold_Desc"] = "Warn in chat if execution time exceeds this value"
L["Items Count"] = "items"

-- =========================================================
-- 3. 简体中文: zhCN
-- =========================================================
if locale == "zhCN" then

    L["AddonName"] = "LorisID |cFF00FF00[至暗之夜]|r"
    L["Init_Loaded"] = "LorisID 已加载。至暗之夜 12.0 API 已就绪。"
    L["Settings"] = "|cff00ff00Loris|r|cffffd700ID|r 插件设置"

    L["Control"] = "控制"
    L["EnableModule"] = "启用模块"
    L["Debug Mode"] = "调试模式"
    L["ID Display Settings"] = "ID 显示设置"
    L["Item"] = "物品"
    L["Spell"] = "法术"
    L["Unit"] = "单位"
    L["Quest"] = "任务"
    L["Achievement"] = "成就"
    L["Currency"] = "货币"
    L["Mount"] = "坐骑"
    L["Toy"] = "玩具"
    L["Talent"] = "天赋"
    L["Icon"] = "图标"
    L["Performance & Cache"] = "性能与缓存"
    L["Enable high-performance LRU cache"] = "启用高性能 LRU 缓存"
    L["Cache Size Limit"] = "缓存容量上限"
    L["Performance Audit Warning Threshold"] = "性能审计警告阈值"

    L["Spell ID"] = "技能 ID"
    L["Item ID"] = "物品 ID"
    L["Unit ID"] = "单位 ID"
    L["NPC ID"] = "NPC ID"
    L["Quest ID"] = "任务 ID"
    L["Achievement ID"] = "成就 ID"
    L["Currency ID"] = "货币 ID"
    L["Mount ID"] = "坐骑 ID"
    L["Toy ID"] = "玩具 ID"
    L["Icon ID"] = "图标 ID"
    L["Talent ID"] = "天赋 ID"
    L["Set ID"] = "套装 ID"
    L["Equipment Set ID"] = "套装 ID"
    L["Visual ID"] = "幻化 ID"

    L["Item_Level"] = "装等"
    L["Stack_Size"] = "堆叠上限"
    L["Item_Price"] = "售价"
    L["Unit_Classification"] = "分类"
    L["GUID"] = "唯一标识(GUID)"
    L["Target of"] = "目标的目标"
    L["Expansion"] = "归属版本"
    L["Count"] = "层数"
    L["Instance ID"] = "实例 ID"
    L["SecretValueBlocked"] = "动作被拦截：逻辑尝试在战斗中对“秘密值”进行运算。"
    L["RestrictedEnvironment"] = "当前处于受限环境（大秘境/竞技场/战斗中）。部分 UI 逻辑已锁定。"
    L["PerfAlert"] = "性能警告：插件执行耗时超过阈值！"

    L["Cmd_Config"] = "打开设置面板"
    L["Cmd_Cache"] = "清除数据缓存"
    L["Cmd_Version"] = "显示版本信息"
    L["Cmd_Help"] = "命令行帮助"
    L["Clear All"] = "清理全部"
    L["Toggle Debug Mode"] = "切换调试模式"
    L["Combat Ended"] = "战斗结束，安全审计模式降级。"
    L["Engine Started"] = "12.0 至暗之夜核心控制引擎启动成功。"
    L["Audit Report"] = "物品详细审计报告"
    L["Scanning Auras"] = "正在扫描单位 %s 的 12.0 光环数据..."
    L["Settings_Enable_Desc"] = "开启或关闭 LorisID 的全部提示功能"
    L["Settings_Debug_Desc"] = "开启 12.0 C_AddOnProfiler 性能审计输出"
    L["Settings_Cache_Desc"] = "显著降低在大城市或大规模战斗中的卡顿"
    L["Settings_CacheSize_Desc"] = "超过此数量将触发 LRU 淘汰算法"
    L["Settings_Threshold_Desc"] = "单次函数耗时超过此值将在聊天框输出警告"
    L["Items Count"] = "项"
end

-- =========================================================
-- 4. 繁体中文: zhTW (还原 David W Zhang 原版翻译)
-- =========================================================
if locale == "zhTW" then
    L["AddonName"] = "LorisID |cFF00FF00[至暗之夜]|r"
    L["Init_Loaded"] = "LorisID 已加載。至暗之夜 12.0 API 已就緒。"
    L["Settings"] = "|cff00ff00Loris|r|cffffd700ID|r 插件設置"

    L["Control"] = "控制"
    L["EnableModule"] = "啟用模組"
    L["Debug Mode"] = "除錯模式"
    L["ID Display Settings"] = "ID 顯示設置"
    L["Item"] = "物品"
    L["Spell"] = "法術"
    L["Unit"] = "單位"
    L["Quest"] = "任務"
    L["Achievement"] = "成就"
    L["Currency"] = "貨幣"
    L["Mount"] = "坐騎"
    L["Toy"] = "玩具"
    L["Talent"] = "天賦"
    L["Icon"] = "圖標"
    L["Performance & Cache"] = "性能與緩存"
    L["Enable high-performance LRU cache"] = "啟用高性能 LRU 緩存"
    L["Cache Size Limit"] = "緩存容量上限"
    L["Performance Audit Warning Threshold"] = "性能審計警告閾值"

    L["Spell ID"] = "技能 ID"
    L["Item ID"] = "物品 ID"
    L["Unit ID"] = "單位 ID"
    L["NPC ID"] = "NPC ID" -- 修正
    L["Quest ID"] = "任務 ID" -- 修正
    L["Achievement ID"] = "成就 ID" -- 修正
    L["Currency ID"] = "貨幣 ID" -- 修正
    L["Mount ID"] = "坐騎 ID" -- 修正
    L["Toy ID"] = "玩具 ID"
    L["Icon ID"] = "圖標 ID"
    L["Talent ID"] = "天賦 ID"
    L["Set ID"] = "套裝 ID"
    L["Equipment Set ID"] = "套裝 ID"
    L["Visual ID"] = "幻化 ID"

    L["Item_Level"] = "物品等級"
    L["Stack_Size"] = "堆疊上限"
    L["Item_Price"] = "售價"
    L["Unit_Classification"] = "分類"
    L["GUID"] = "唯一標識(GUID)"
    L["Target of"] = "目標的目標"
    L["Expansion"] = "歸屬版本"
    L["Count"] = "層數"
    L["Instance ID"] = "實例 ID"
    L["SecretValueBlocked"] = "動作被攔截：邏輯嘗試在戰鬥中對“秘密值”進行運算。"
    L["RestrictedEnvironment"] = "當前處於受限環境（大秘境/競技場/戰鬥中）。部分 UI 邏輯已鎖定。"
    L["PerfAlert"] = "性能警告：插件執行耗時超過閾值！"

    L["Cmd_Config"] = "打開設置面板"
    L["Cmd_Cache"] = "清除數據緩存"
    L["Cmd_Version"] = "顯示版本信息"
    L["Cmd_Help"] = "命令行幫助"
    L["Clear All"] = "清理全部"
    L["Toggle Debug Mode"] = "切換除錯模式"
    L["Combat Ended"] = "戰鬥結束，安全審計模式降級。"
    L["Engine Started"] = "12.0 至暗之夜核心控制引擎啟動成功。"
    L["Audit Report"] = "物品詳細審計報告"
    L["Scanning Auras"] = "正在掃描單位 %s 的 12.0 光環數據..."
    L["Settings_Enable_Desc"] = "開啟或關閉 LorisID 的全部提示功能"
    L["Settings_Debug_Desc"] = "開啟 12.0 C_AddOnProfiler 性能審計輸出"
    L["Settings_Cache_Desc"] = "顯著降低在大城市或大規模戰鬥中的卡頓"
    L["Settings_CacheSize_Desc"] = "超過此數量將觸發 LRU 淘汰算法"
    L["Settings_Threshold_Desc"] = "單次函數耗時超過此值將在聊天框輸出警告"
    L["Items Count"] = "項"
end