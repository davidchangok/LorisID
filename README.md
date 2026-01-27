[简体中文](README_CN.md) | English

---

# LorisID - World of Warcraft ID Query and Display Addon

**LorisID** is a high-performance ID display and data query addon specifically designed for World of Warcraft Retail (Midnight). It is fully adapted to the latest **12.0 (Midnight)** API architecture, aiming to provide accurate and safe data feedback for developers, dataminers, and hardcore players.

## Core Features

### 1. Comprehensive ID Detection
Automatically injects raw IDs of various objects into in-game Tooltips, supporting the following types:
* **Basic Types**: Item, Spell, Unit/NPC, Quest, Achievement.
* **Collections**: Mount, Pet/Companion, Toy, Visual (Transmog).
* **System Data**: Currency, Heart of Azeroth/Talent, Equipment Set.
* **Related Data**: Automatically detects associated **Icon IDs** and **Trigger Spell IDs**.

### 2. Modern API Architecture (12.0 Ready)
Abandons outdated Hook methods and fully adopts Blizzard's modern API standards to ensure stability in future versions:
* **TooltipDataProcessor**: Uses officially recommended post-processing hooks, compatible with all UI addons based on the new framework.
* **MenuUtil**: Adopts the new context menu system, completely solving the taint issues of `UIDropDownMenu`.
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
* **ID Type Filtering**: Individually control whether to display IDs for items, spells, units, etc.
* **Performance Settings**:
    * **LRU Cache**: Enable/Disable and set the maximum number of cache entries (default 1000).
    * **Performance Threshold**: Set the function execution time warning threshold (milliseconds) to troubleshoot lag sources.

## Technical Details (For Developers)

* **Namespace**: All modules are mounted under the `ns` table to avoid global variable pollution.
* **Localization**: Supports `enUS`, `zhCN`, `zhTW`, using a metatable fallback mechanism to prevent missing Key errors.
* **UI Interaction**: Uses `IsMouseMotionFocus()` instead of the deprecated `GetMouseFocus()` to support high-precision mouse detection.

## FAQ

**Q: Why do some values display as "???" or purple during combat?**
A: This is the addon's "Secret Value Protection" mechanism at work. Blizzard restricts addons from accessing certain protected values (such as unfiltered damage/healing amounts) during combat. LorisID automatically masks this data to prevent the addon from crashing or being blocked by the system.

**Q: Why can't I see certain IDs?**
A: Please check the settings panel to see if the corresponding ID type is checked, or if the UI element supports the standard `TooltipData` interface.

---
**Author**: David W Zhang
**Version**: Adapted for World of Warcraft 11.0+ / 12.0 Pre-patch