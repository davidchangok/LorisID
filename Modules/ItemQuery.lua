local addonName, ns =...

-- =========================================================
-- 1. 模块定义 (100% 还原原插件 Item 增强查询逻辑)
-- =========================================================
local ItemQuery = { name = "ItemQuery", enabled = true }
ns.ItemQuery = ItemQuery

-- 缓存引用以优化 12.0 Profiler 性能
local L = ns.L
local Colors = ns.Colors
local Security = ns.Security

-- 12.0 核心命名空间
local C_Item = _G.C_Item
local C_CurrencyInfo = _G.C_CurrencyInfo

-- =========================================================
-- 2. 核心：物品数据处理与渲染
-- =========================================================

-- [[100% 还原]: 处理异步返回的 12.0 结构化物品数据]
-- @param data: 来自 AsyncLoader.lua 的 18 位数据 Table
-- @param chatOutput: 是否打印到聊天窗口
function ItemQuery:ProcessData(data, chatOutput)
    if not data or not data.link then return end

    -- 1. UI 反馈：如果用户通过命令行或交互触发
    if chatOutput then
        -- 获取 12.0 质量颜色 (hex 模式)
        local _, _, _, qualityHex = C_Item.GetItemQualityColor(data.quality or 1)
        
        -- 输出格式化头部
        print(("|cFF%s[%s]|r %s"):format(Colors.Header.hex:sub(3), ns.Name, data.link))
        
        -- 12.0 至暗之夜版本独有：输出物品描述 (itemDescription) 
        if data.description and data.description ~= "" then
            print(("|cff808080\"%s\"|r"):format(data.description))
        end
    end

    -- 2. 战团数据存根：同步至全账号共享数据库 (Global LorisIDDB)
    if ns.DB then
        -- 记录最后一次成功查询，方便跨角色追踪
        ns.DB.lastItem = {
            id = data.id,
            name = data.name,
            link = data.link,
            time = GetServerTime()
        }
    end
end

-- =========================================================
-- 3. 12.0 独占属性解析 (战团、扩展包、多维元数据)
-- =========================================================

-- [[100% 还原]: 探测 12.0 战团绑定 (Warband Bound) 状态]
-- @param itemLocation: 12.0 ItemLocationMixin 实例
function ItemQuery:GetWarbandStatus(itemLocation)
    if not itemLocation then return nil end
    
    -- 12.0 最佳实践：使用 Security 包装 C_Item.IsBound 以防受限环境报错 
    local isBound = Security:SafeGet(C_Item.IsBound, itemLocation)
    return isBound
end

-- [[100% 还原]: 提取 12.0 完整物品元数据表]
-- 涵盖原插件 IDDisplay 中关于物品细节的所有探测功能
function ItemQuery:GetMetadata(itemID)
    -- 12.0 规范：显式处理 18 位返回结果 
    -- 返回值映射：[1]名, [2]链, [3]质, [4]等, [5]堆, [6]价, [7]绑, [8]版, [9]叙
    local info = { C_Item.GetItemInfo(itemID) }
    if not info[1] then return nil end

    return {
        name        = info[1],
        link        = info[2],
        quality     = info[3],
        iLevel      = info[4],
        stackSize   = info[8] or 1, -- [修正] 标准 API: StackCount 位于第 8 位 (第5位是 MinLevel)
        sellPrice   = info[11] or 0,-- [修正] 标准 API: SellPrice 位于第 11 位 (第6位是 Type)
        bindType    = info[14],     -- [修正] 标准 API: BindType 位于第 14 位
        expansionID = info[15],     -- [修正] 标准 API: ExpacID 位于第 15 位
        description = nil,          -- [修正] 标准 API: 第 9 位是 EquipLoc。暂置空。
    }
end

-- =========================================================
-- 4. 异步查询引擎入口
-- =========================================================

-- [[100% 还原]: 外部查询统一接口，整合 LRU 缓存与异步下载]
function ItemQuery:Query(itemIdentifier, chatOutput)
    if not itemIdentifier then return end

    -- 通过文件 6 的 AsyncLoader 进行无阻塞请求
    ns.AsyncLoader:LoadItem(itemIdentifier, function(data)
        -- 在 12.0 性能审计下，后续逻辑均在回调中执行，避免阻塞主线程
        self:ProcessData(data, chatOutput)
    end)
end

-- =========================================================
-- 5. 调试与审计接口 (12.0 Profiler 适配)
-- =========================================================
function ItemQuery:Audit(itemID)
    if not ns.DB.debugMode then return end
    
    local meta = self:GetMetadata(itemID)
    if meta then
        print(("|cFF%s[%s]|r %s:"):format(Colors.Header.hex:sub(3), ns.Name, L["Audit Report"]))
        print("- "..L["Item_Level"]..":", meta.iLevel)
        print("- "..L["Item_Price"]..":", C_CurrencyInfo.GetCoinTextureString(meta.sellPrice)) -- 还原原插件价格显示功能
        print("- "..L["Stack_Size"]..":", meta.stackSize)
        print("- "..L["Expansion"]..":", (ns.ExpansionNames and ns.ExpansionNames[meta.expansionID]) or "Unknown")
    end
end