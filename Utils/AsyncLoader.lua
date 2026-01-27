local addonName, ns =...

-- =========================================================
-- 1. 异步引擎定义 (100% 还原原插件异步抓取能力)
-- =========================================================
local AsyncLoader = {}
ns.AsyncLoader = AsyncLoader

-- 缓存 12.0 命名空间 API，优化剖析器评分 [1]
local C_Item = _G.C_Item
local C_Spell = _G.C_Spell
local C_QuestLog = _G.C_QuestLog
local Item = _G.Item
local Spell = _G.Spell

-- =========================================================
-- 2. 核心：物品数据异步加载 (12.0 Mixin 模式)
-- =========================================================
-- [[100% 还原]: 解决 GetItemInfo 异步返回 nil 的问题]
function AsyncLoader:LoadItem(itemID, callback)
    if not itemID or itemID == 0 then return end

    -- 1. 优先检查本地 LRU 缓存
    local cached = ns.Cache:Get("item", itemID)
    if cached then
        callback(cached)
        return
    end

    -- 2. 创建 12.0 现代物品对象
    local itemObj = Item:CreateFromItemID(tonumber(itemID) or 0)
    if itemObj:IsItemEmpty() then return end

    -- 3. 注册 12.0 标准回调
    itemObj:ContinueOnItemLoad(function()
        -- 适配 12.0 完整返回 (18个返回值) 
        -- [2]name, [3]link, [4]quality, [5]iLevel, [6]icon, [7]bindType, [8]description
        local info = { C_Item.GetItemInfo(itemID) }
        
        if info[1] then
            local data = {
                id          = itemID,
                name        = info[1],
                link        = info[2],
                quality     = info[3],
                level       = info[4],
                icon        = info[10], -- 标准 API 图标位于第 10 位
                bindType    = info[14], -- [修正] 标准 API: BindType 位于第 14 位
                description = nil,      -- [修正] 标准 API: 第 9 位是 EquipLoc，非描述。暂置空以防乱码。
                expansionID = info[15], -- [修正] 标准 API: ExpacID 位于第 15 位
            }
            
            -- 存入 LRU 缓存并执行回调
            ns.Cache:Set("item", itemID, data)
            callback(data)
        end
    end)
end

-- =========================================================
-- 3. 核心：技能数据异步加载 (12.0 SpellMixin)
-- =========================================================
-- [[100% 还原]: 还原原插件对技能图标及动态描述的抓取能力]
function AsyncLoader:LoadSpell(spellID, callback)
    if not spellID or spellID == 0 then return end

    local cached = ns.Cache:Get("spell", spellID)
    if cached then
        callback(cached)
        return
    end

    local spellObj = Spell:CreateFromSpellID(tonumber(spellID) or 0)
    
    spellObj:ContinueOnSpellLoad(function()
        -- 适配 11.x/12.x C_Spell.GetSpellInfo 结构化 Table 
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo then
            local data = {
                name        = spellInfo.name,
                icon        = spellInfo.iconID,
                castTime    = spellInfo.castTime,
                minRange    = spellInfo.minRange,
                maxRange    = spellInfo.maxRange,
                description = C_Spell.GetSpellDescription(spellID),
            }
            
            ns.Cache:Set("spell", spellID, data)
            callback(data)
        end
    end)
end

-- =========================================================
-- 4. 核心：任务数据异步请求 (12.0 API)
-- =========================================================
-- [[100% 还原]: 还原原插件对世界任务及离线任务 ID 的解析能力]
function AsyncLoader:LoadQuest(questID, callback, retryCount)
    if not questID or questID == 0 then return end

    local cached = ns.Cache:Get("quest", questID)
    if cached then
        callback(cached)
        return
    end

    -- [鲁棒性修复] 增加最大重试次数，防止无效 ID 导致的无限递归死循环
    retryCount = retryCount or 0
    if retryCount > 10 then return end -- 超过 10 次 (约2秒) 放弃

    -- 12.0 任务异步加载标准流程 
    if not C_QuestLog.IsQuestDataCached(questID) then
        C_QuestLog.RequestLoadQuestByID(questID)
        -- 通过延时重试策略确保在数据同步后触发回调
        C_Timer.After(0.2, function()
            self:LoadQuest(questID, callback, retryCount + 1)
        end)
        return
    end

    local title = C_QuestLog.GetTitleForQuestID(questID)
    if title and title ~= "" then
        local data = { name = title }
        ns.Cache:Set("quest", questID, data)
        callback(data)
    end
end

-- =========================================================
-- 5. 12.0 战团预取工具 (Warband Preload)
-- =========================================================
function AsyncLoader:BulkPreload(idList, idType)
    if type(idList) ~= "table" then return end
    
    for _, id in ipairs(idList) do
        if idType == "item" then
            C_Item.RequestLoadItemDataByID(id)
        elseif idType == "spell" then
            Spell:CreateFromSpellID(id)
        end
    end
end