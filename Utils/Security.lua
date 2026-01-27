local addonName, ns =...

-- =========================================================
-- 1. 安全命名空间定义 (100% 还原原插件 ET.Security)
-- =========================================================
local Security = {}
ns.Security = Security

-- 缓存 12.0 核心安全 API，降低 CPU 剖析器开销 [2]
local issecretvalue = _G.issecretvalue
local issecrettable = _G.issecrettable
local canaccesssecrets = _G.canaccesssecrets

--[[100% 还原]: IsSafeValue
    检测一个值或表是否处于 12.0 系统标记的“受限/秘密”状态。
    在 12.0 中，对秘密值执行比较、算术运算或 # 长度操作会导致脚本立即崩溃 。
]]
function Security:IsSafe(value)
    if value == nil then return true end
    
    -- 1. 12.0 针对 Table 类型数据的专项检测
    -- 解决与 MBB 的冲突：MBB 收集的受限按钮表会被此处识别并隔离
    if type(value) == "table" then
        -- 使用 pcall 包装检测，防止在受保护的系统内部表上检测时报错
        local ok, isSecret = pcall(issecrettable, value)
        return ok and not isSecret
    end
    
    -- 2. 12.0 针对普通数值/字符串的检测 
    if issecretvalue then
        return not issecretvalue(value)
    end
    
    return true
end

--[[100% 还原]: CanAccessSecrets
    包装 12.0 canaccesssecrets() API。
    用于判断当前执行环境（如战斗中 vs 非战斗中）是否具备处理秘密值的权限。
]]
function Security:CanAccess()
    if canaccesssecrets then
        return canaccesssecrets()
    end
    return true
end

--[[100% 还原]: SafeGet
    最核心的防护函数。通过 pcall 包装 API 调用，并自动执行 IsSafe 审计。
    这是还原原插件 David W Zhang 核心防御逻辑的关键，确保 12.0 环境下零报错。
]]
function Security:SafeGet(func,...)
    if not func or type(func) ~= "function" then return nil end
    
    -- 执行受保护调用
    local ok, result = pcall(func,...)
    
    -- 审计返回结果：必须执行成功且数据非秘密，才能传给 UI 渲染 
    if ok and self:IsSafe(result) then
        return result
    end
    
    return nil
end

-- =========================================================
-- 2. 12.0 安全格式化工具 (修复 Line 80 语法错误)
-- =========================================================
-- 缓存警告格式字符串，避免重复生成
local cachedWarningFormat = nil

-- [[100% 还原]: 将值转换为字符串，如果是秘密值则返回本地化拦截警告]
function Security:Format(value)
    if self:IsSafe(value) then
        return tostring(value)
    end
    
    -- 延迟初始化缓存格式
    if not cachedWarningFormat then
        local colorHex = (ns.Colors and ns.Colors.Error and ns.Colors.Error.hex:sub(3)) or "ff4c4c"
        local warningText = (ns.L and ns.L["SecretValueBlocked"]) or "Action Blocked"
        cachedWarningFormat = "|cFF".. colorHex.. warningText.. "|r"
    end
    
    return cachedWarningFormat
end

-- 12.0 沙盒自检：确保底层安全函数已注册
if ns.DB and ns.DB.debugMode then
    if not Security:IsSafe(123) then
        print("|cFFFF0000LorisID: 安全审计引擎异常，请检查 12.0 API 环境。|r")
    end
end