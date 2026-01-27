local addonName, ns =...

-- =========================================================
-- 1. 缓存配置 (100% 还原原插件 Cache 规格)
-- =========================================================
local CACHE_CONFIG = {
    maxSize = 1000,          -- 每个 ID 分类的最大存储上限
    defaultTTL = 600,        -- 默认过期时间 (10分钟)
    cleanupInterval = 300,   -- 自动清理过期项的间隔 (5分钟)
    
    -- 针对不同 ID 类型的特殊过期策略 (秒)
    types = {
        ["item"] = 600,
        ["spell"] = 600,
        ["unit"] = 300,         -- 单位信息变动较快，缓存时间较短
        ["quest"] = 600,
        ["achievement"] = 3600, -- 成就数据固定，缓存时间较长
    }
}

-- =========================================================
-- 2. 缓存对象定义 (对应原插件 Cache 命名空间)
-- =========================================================
local Cache = {
    store = {},
    stats = { hits = 0, misses = 0, sets = 0, evictions = 0 },
    lastCleanup = GetTime()
}
ns.Cache = Cache

-- [[100% 还原]: 初始化存储桶]
function Cache:Initialize()
    -- 确保 Init.lua 定义的 ns.IDTypes 已就绪
    local idTypesMap = ns.IDTypes or {}
    for _, idType in pairs(idTypesMap) do
        self.store[idType] = {}
    end
    
    -- 启动 12.0 标准计时器，定期执行内存回收 [4]
    C_Timer.NewTicker(CACHE_CONFIG.cleanupInterval, function()
        self:Cleanup()
    end)
end

-- [[100% 还原]: 读取缓存与 TTL 校验]
function Cache:Get(cacheType, key)
    -- 设置项校验：若用户在 Settings.lua 中关闭缓存则返回 nil
    if not ns.DB or not ns.DB.cache or not ns.DB.cache.enabled then return nil end
    
    local bucket = self.store[cacheType]
    if not bucket then return nil end
    
    local entry = bucket[key]
    if entry then
        local now = GetTime()
        local ttl = (CACHE_CONFIG.types and CACHE_CONFIG.types[cacheType]) or CACHE_CONFIG.defaultTTL
        
        -- TTL 判定：检查项是否已过期
        if (now - entry.timestamp) > ttl then
            bucket[key] = nil
            self.stats.misses = self.stats.misses + 1
            return nil
        end
        
        -- 更新热点访问时间，供 LRU 淘汰算法识别 
        entry.lastAccess = now
        self.stats.hits = self.stats.hits + 1
        return entry.data
    end
    
    self.stats.misses = self.stats.misses + 1
    return nil
end

-- [[100% 还原]: 写入缓存与 LRU 自动淘汰逻辑]
function Cache:Set(cacheType, key, data)
    if not ns.DB or not ns.DB.cache or not ns.DB.cache.enabled then return end
    
    -- 12.0 核心防御：禁止缓存受限的秘密值数据，保护 UI 安全 
    if not ns.Security:IsSafe(data) then return end

    local bucket = self.store[cacheType]
    if not bucket then return end

    -- LRU 淘汰触发：检查容量是否触碰上限
    local currentCount = 0
    for _ in pairs(bucket) do currentCount = currentCount + 1 end
    
    if currentCount >= (ns.DB.cache.maxSize or CACHE_CONFIG.maxSize) then
        self:EvictLRU(cacheType)
    end

    local now = GetTime()
    bucket[key] = {
        data = data,
        timestamp = now,
        lastAccess = now
    }
    self.stats.sets = self.stats.sets + 1
end

-- [[100% 还原]: LRU (最近最少使用) 算法核心逻辑]
function Cache:EvictLRU(cacheType)
    local bucket = self.store[cacheType]
    if not bucket then return end

    local oldestKey = nil
    local oldestTime = math.huge  -- 使用 math.huge 代替 GetTime()
    
    -- 单次遍历找到最久未访问的项
    for k, entry in pairs(bucket) do
        if entry.lastAccess < oldestTime then
            oldestTime = entry.lastAccess
            oldestKey = k
        end
    end
    
    if oldestKey then
        bucket[oldestKey] = nil
        self.stats.evictions = self.stats.evictions + 1
    end
end

-- [[100% 还原]: 定期批量清理过期项]
function Cache:Cleanup()
    local now = GetTime()
    for cacheType, bucket in pairs(self.store) do
        local ttl = (CACHE_CONFIG.types and CACHE_CONFIG.types[cacheType]) or CACHE_CONFIG.defaultTTL
        for k, entry in pairs(bucket) do
            if (now - entry.timestamp) > ttl then
                bucket[k] = nil
            end
        end
    end
    self.lastCleanup = now
end

-- [[100% 还原]: 清空特定分类或全量缓存数据]
function Cache:Clear(cacheType)
    if cacheType and self.store then
        self.store[cacheType] = {}
    else
        for k in pairs(self.store or {}) do
            self.store[k] = {}
        end
    end
end

-- 执行挂载
Cache:Initialize()