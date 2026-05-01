English | 简体中文

---

# LorisID - World of Warcraft ID Query and Display Addon

**LorisID** is a high-performance ID display and data query addon specifically designed for World of Warcraft Retail (Midnight). It is fully adapted to the latest **12.0 (Midnight)** API architecture, aiming to provide accurate and safe data feedback for developers, dataminers, and hardcore players.

## Core Features

### 1. Comprehensive ID Detection
Automatically injects raw IDs of various objects into in-game Tooltips, supporting 20 ID types:
* **Basic Types**: Item, Spell, Unit/NPC, Quest, Achievement.
* **Collections**: Mount, Companion, Toy, Visual (Transmog), Equipment Set.
* **System Data**: Currency, Talent, Icon, PvP Brawl, Minimap.
* **Misc**: Object, Battle Pet, Instance, Recipe, Macro.
* **Related Data**: Automatically detects associated **Icon IDs** and **Trigger Spell IDs**.

### 2. Modern API Architecture (12.0 Ready)
Abandons outdated Hook methods and fully adopts Blizzard's modern API standards to ensure stability in future versions:
* **TooltipDataProcessor**: Uses officially recommended post-processing hooks, compatible with all UI addons based on the new framework.
* **MenuUtil**: Adopts the new context menu system, completely solving the taint issues of `UIDropDownMenu`.
* **Settings Canvas Layout**: Integrated with 12.0's `Settings.RegisterCanvasLayoutCategory` API, fully native settings panel with scroll support.
* **C_Item & Warband**: Supports **Warband** binding status detection and new item description fields added in 12.0.

### 3. Enterprise-Grade Security & Performance
* **Secret Value Protection**: Built-in security audit module that automatically identifies and masks protected values during combat (such as dynamic absorption amounts) to prevent addon errors or functional failures caused by accessing restricted memory.
* **LRU Cache System**: Built-in high-performance caching algorithm to automatically manage memory usage during large-scale combat or in capital cities.
* **Performance Audit**: Integrated with `C_AddOnProfiler`, supporting real-time CPU usage monitoring and latency warnings.

### 4. Developer Tools
* **AuraScanner**: Provides an efficient aura traversal tool based on `AuraUtil.ForEachAura`, supporting the export of SpellID and InstanceID.
* **Async Item Query**: Encapsulates `ns.AsyncLoader` to support non-blocking item metadata loading.

## Installation & Usage

1.  Extract the `LorisID` folder to your World of Warcraft AddOns directory:
    `_retail_\Interface\AddOns\`
2.  Enter the game, and the addon will load automatically.

### Command Line Instructions

Supports `/lid`, `/lorisid`, `/et` command prefixes:

* `/lid config` or `/lid settings`
    * Open the settings panel (integrated in System ESC -> Options -> AddOns).
* `/lid cache [type]`
    * Clear data cache. For example, `/lid cache item` clears item cache, `/lid cache` clears all.
* `/lid debug`
    * Toggle debug mode. When enabled, detailed API call logs and performance warnings will be output to the chat frame.
* `/lid version`
    * Display current version information.

## Configuration Options

Through the settings panel, you can customize the following:
* **Module Switch**: Enable or disable all functions with one click.
* **ID Type Filtering**: Individually control whether to display IDs for all 20 supported types across a 3-column layout.
* **Performance Settings**:
    * **LRU Cache**: Enable/Disable and set the maximum number of cache entries (100–5000, default 1000).
    * **Performance Threshold**: Set the function execution time warning threshold (1–100 ms), used to troubleshoot lag sources.

## Localization

Supports **10 languages** across 2 localization modules:

| File               | Languages                                    |
|--------------------|----------------------------------------------|
| `Localization.lua` | enUS (default), zhCN, zhTW, koKR, deDE       |
| `Localization2.lua`| frFR, esES/esMX, ruRU, ptBR, itIT            |

Uses a metatable fallback mechanism — missing keys in any locale automatically fall back to the English default.

## Technical Details (For Developers)

* **Namespace**: All modules are mounted under the `ns` table to avoid global variable pollution.
* **File Architecture**:
  * `Core Layer`: Localization (2 files), Init (DB + constants)
  * `Utils Layer`: Security audit, LRU Cache, Async Loader
  * `Modules Layer`: IDDisplay, AuraScanner, ItemQuery, UIComponents
  * `Presentation Layer`: Settings (Canvas Layout)
  * `Entry Layer`: Core (lifecycle + slash commands)
* **Settings Panel**: Built with `UIPanelScrollFrameTemplate` following the Canvas Layout pattern, registered on `ADDON_LOADED` for proper system integration.
* **UI Interaction**: Uses `IsMouseMotionFocus()` instead of the deprecated `GetMouseFocus()` to support high-precision mouse detection.

## FAQ

**Q: Why do some values display as "???" or purple during combat?**
A: This is the addon's "Secret Value Protection" mechanism at work. Blizzard restricts addons from accessing certain protected values (such as unfiltered damage/healing amounts) during combat. LorisID automatically masks this data to prevent the addon from crashing or being blocked by the system.

**Q: Why can't I see certain IDs?**
A: Please check the settings panel to see if the corresponding ID type is checked, or if the UI element supports the standard `TooltipData` interface.

---
**Author**: David W Zhang
**Version**: 2.3.0
**Game Version**: World of Warcraft 12.0 (Midnight)
**License**: MIT

[English](#lorisid---world-of-warcraft-id-query-and-display-addon) | 简体中文

---

# LorisID - 魔兽世界 ID 查询与显示插件

**LorisID** 是一款专为魔兽世界正式服至暗之夜版本（Retail）专门设计的高性能 ID 显示与数据查询插件。它完全适配 **12.0（至暗之夜）** 的最新 API 架构，旨在为开发者、数据挖掘者及硬核玩家提供精准、安全的数据反馈。

## 核心特性

### 1. 全面的 ID 探测
在游戏内的鼠标提示（Tooltip）中自动注入各类对象的原始 ID，支持 20 种类型：
* **基础类型**: 物品 (Item)、法术 (Spell)、单位 (Unit/NPC)、任务 (Quest)、成就 (Achievement)。
* **收藏品**: 坐骑 (Mount)、伙伴 (Companion)、玩具 (Toy)、幻化 (Visual)、套装 (Equipment Set)。
* **系统数据**: 货币 (Currency)、天赋 (Talent)、图标 (Icon)、PvP 乱斗、小地图 (Minimap)。
* **其他**: 游戏对象 (Object)、对战宠物 (Battle Pet)、副本 (Instance)、配方 (Recipe)、宏 (Macro)。
* **关联数据**: 自动探测关联的 **图标 ID** 和 **触发法术 ID**。

### 2. 现代 API 架构（12.0 就绪）

摒弃过时的 Hook 方式，全面采用暴雪现代 API 标准，确保未来版本中的稳定性：
* **TooltipDataProcessor**: 使用官方推荐的后处理钩子，兼容所有基于新框架的 UI 插件。
* **MenuUtil**: 采用新版上下文菜单系统，彻底解决 `UIDropDownMenu` 的污染问题。
* **Settings Canvas Layout**: 集成 12.0 原生 `Settings.RegisterCanvasLayoutCategory` API，设置面板自带滚动支持，与系统无缝融合。
* **C_Item & Warband**: 支持 **战团 (Warband)** 绑定状态检测及 12.0 新增的物品描述字段。

### 3. 企业级安全性与性能
* **秘密值防御 (Secret Value Protection)**: 内置安全审计模块，自动识别并屏蔽战斗中受保护的数值（如动态吸收量），防止因访问受限内存导致的插件报错或功能失效。
* **LRU 缓存系统**: 内置高性能缓存算法，在大规模战斗或主城中自动管理内存占用。
* **性能审计**: 集成 `C_AddOnProfiler`，支持实时 CPU 占用监控与耗时预警。

### 4. 开发者工具
* **光环扫描器 (AuraScanner)**: 提供基于 `AuraUtil.ForEachAura` 的高效光环遍历工具，支持导出 SpellID 和 InstanceID。
* **异步物品查询**: 封装 `ns.AsyncLoader`，支持非阻塞式的物品元数据加载。

## 安装与使用

1.  将 `LorisID` 文件夹解压至魔兽世界插件目录：
    `_retail_\Interface\AddOns\`
2.  进入游戏，插件将自动加载。

### 命令行指令

支持 `/lid`、`/lorisid`、`/et` 命令前缀：

* `/lid config` 或 `/lid settings`
    * 打开设置面板（集成于系统 ESC → 选项 → 插件）。
* `/lid cache [type]`
    * 清除数据缓存。例如 `/lid cache item` 清除物品缓存，`/lid cache` 清除全部。
* `/lid debug`
    * 切换调试模式。开启后将在聊天框输出详细的 API 调用日志和性能警告。
* `/lid version`
    * 显示当前版本信息。

## 设置选项

通过设置面板，您可以自定义以下内容：
* **模块开关**: 一键启用或禁用所有功能。
* **ID 类型过滤**: 三列布局，单独控制全部 20 种类型的 ID 显示。
* **性能设置**:
    * **LRU 缓存**: 开启/关闭及设置最大缓存条目数（100–5000 条，默认 1000）。
    * **性能阈值**: 设定函数执行耗时警告线（1–100 毫秒），用于排查卡顿源。

## 多语言支持

支持 **10 种语言**，分为两个本地化模块：

| 文件               | 语言                                        |
|--------------------|---------------------------------------------|
| `Localization.lua` | enUS（默认）、zhCN、zhTW、koKR、deDE        |
| `Localization2.lua`| frFR、esES/esMX、ruRU、ptBR、itIT           |

采用元表回退机制——任意语言中缺失的条目自动回退至英文默认值。

## 技术细节（面向开发者）

* **命名空间**: 所有模块挂载于 `ns` 表下，避免全局变量污染。
* **文件架构**:
  * `核心层`: 本地化（2 文件）、Init（数据库 + 常量）
  * `工具层`: 安全审计、LRU 缓存、异步加载器
  * `模块层`: IDDisplay、AuraScanner、ItemQuery、UIComponents
  * `表现层`: Settings（Canvas Layout 原生设置面板）
  * `入口层`: Core（生命周期 + 斜杠命令）
* **设置面板**: 采用 `UIPanelScrollFrameTemplate` 构建，遵循 Canvas Layout 模式，在 `ADDON_LOADED` 阶段注册至系统设置。
* **UI 交互**: 使用 `IsMouseMotionFocus()` 替代废弃的 `GetMouseFocus()`，支持高精度鼠标探测。

## 常见问题

**Q: 为什么战斗中部分数值显示为 "???" 或紫色？**
A: 这是插件的"秘密值防御"机制在工作。暴雪限制了插件在战斗中访问某些受保护的数值（如未过滤的伤害/治疗量）。LorisID 会自动脱敏这些数据以防止插件崩溃或被系统封锁。

**Q: 为什么我看不到某些 ID？**
A: 请检查设置面板中是否勾选了对应的 ID 类型，或者该 UI 元素是否支持标准的 `TooltipData` 接口。

---
**作者**: David W Zhang
**版本**: 2.3.0
**游戏版本**: World of Warcraft 12.0（至暗之夜）
**协议**: MIT
