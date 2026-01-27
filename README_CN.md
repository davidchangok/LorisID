# LorisID - 魔兽世界 ID 查询与显示插件

**LorisID** 是一款专为魔兽世界正式服至暗之夜版本（Retail）专门设计的高性能 ID 显示与数据查询插件。它完全适配 **12.0 (至暗之夜)** 的最新 API 架构，旨在为开发者、数据挖掘者及硬核玩家提供精准、安全的数据反馈。

## 核心特性

### 1. 全面的 ID 探测
在游戏内的鼠标提示（Tooltip）中自动注入各类对象的原始 ID，支持以下类型：
*   **基础类型**: 物品 (Item)、法术 (Spell)、单位 (Unit/NPC)、任务 (Quest)、成就 (Achievement)。
*   **收藏品**: 坐骑 (Mount)、宠物/伙伴、玩具 (Toy)、幻化 (Visual)。
*   **系统数据**: 货币 (Currency)、艾泽拉斯之心/天赋 (Talent)、套装 (Equipment Set)。
*   **关联数据**: 自动探测物品关联的 **图标 ID (Icon ID)** 和 **触发法术 ID**。

### 2. 现代 API 架构 (12.0 Ready)
摒弃了过时的 Hook 方式，全面采用暴雪现代 API 标准，确保在未来版本中的稳定性：
*   **TooltipDataProcessor**: 使用官方推荐的后处理钩子，兼容所有基于新框架的 UI 插件。
*   **MenuUtil**: 采用新版上下文菜单系统，彻底解决 `UIDropDownMenu` 的污染问题。
*   **C_Item & Warband**: 支持 **战团 (Warband)** 绑定状态检测及 12.0 新增的物品描述字段。

### 3. 企业级安全性与性能
*   **秘密值防御 (Secret Value Protection)**: 内置安全审计模块，自动识别并屏蔽战斗中受保护的数值（如动态吸收量），防止因访问受限内存导致的插件报错或功能失效。
*   **LRU 缓存系统**: 内置高性能缓存算法，在大规模战斗或主城中自动管理内存占用。
*   **性能审计**: 集成 `C_AddOnProfiler`，支持实时 CPU 占用监控与耗时预警。

### 4. 开发者工具
*   **光环扫描器 (AuraScanner)**: 提供基于 `AuraUtil.ForEachAura` 的高效光环遍历工具，支持导出 SpellID 和 InstanceID。
*   **异步物品查询**: 封装 `ns.AsyncLoader`，支持非阻塞式的物品元数据加载。

## 安装与使用

1.  将 `LorisID` 文件夹解压至魔兽世界插件目录：
    `_retail_\Interface\AddOns\`
2.  进入游戏，插件将自动加载。

### 命令行指令

支持 `/lid`, `/lorisid`, `/et` 命令前缀：

*   `/lid config` 或 `/lid settings`
    *   打开设置面板（集成于系统 ESC -> 选项 -> 插件）。
*   `/lid cache [type]`
    *   清除数据缓存。例如 `/lid cache item` 清除物品缓存，`/lid cache` 清除全部。
*   `/lid debug`
    *   切换调试模式。开启后将在聊天框输出详细的 API 调用日志和性能警告。
*   `/lid version`
    *   显示当前版本信息。

## 配置选项

通过设置面板，您可以自定义以下内容：
*   **模块开关**: 一键启用或禁用所有功能。
*   **ID 类型过滤**: 单独控制是否显示物品、法术、单位等特定类型的 ID。
*   **性能设置**:
*   **LRU 缓存**: 开启/关闭及设置最大缓存条目数（默认 1000 条）。
*   **性能阈值**: 设定函数执行耗时警告线（毫秒），用于排查卡顿源。

## 技术细节 (For Developers)

*   **命名空间**: 所有模块挂载于 `ns` 表下，避免全局变量污染。
*   **本地化**: 支持 `enUS`, `zhCN`, `zhTW`，采用元表回退机制防止 Key 缺失报错。
*   **UI 交互**: 使用 `IsMouseMotionFocus()` 替代废弃的 `GetMouseFocus()`，支持高精度鼠标探测。

## 常见问题

**Q: 为什么战斗中部分数值显示为 "???" 或紫色？**
A: 这是插件的“秘密值防御”机制在工作。暴雪限制了插件在战斗中访问某些受保护的数值（如未过滤的伤害/治疗量）。LorisID 会自动脱敏这些数据以防止插件崩溃或被系统封锁。

**Q: 为什么我看不到某些 ID？**
A: 请检查设置面板中是否勾选了对应的 ID 类型，或者该 UI 元素是否支持标准的 `TooltipData` 接口。

---
**Author**: David W Zhang
**Version**: 适配 World of Warcraft 11.0+ / 12.0 Pre-patch
```

<!--
[PROMPT_SUGGESTION]请帮我生成一个 .toc 文件，包含所有必要的元数据和文件引用列表。[/PROMPT_SUGGESTION]
[PROMPT_SUGGESTION]如何为 AuraScanner 模块添加一个导出功能，将扫描到的光环数据导出为 CSV 格式字符串？[/PROMPT_SUGGESTION]
->