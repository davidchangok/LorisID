# CLAUDE.md — LorisID 项目核心规则

## 每次修改后必须更新 GitHub

**规则**: 每次对代码进行修改后，必须在同一轮对话中完成 git commit 和 git push，将变更同步到 GitHub。

具体步骤：
1. `git add <修改的文件>`
2. `git commit -m "<清晰的 commit message>"`
3. `git push origin main`

**Why**: 确保本地修改与远程仓库始终保持同步，避免代码丢失和版本冲突。

## 语言要求

与本项目（LorisID）相关的所有对话、分析、注释和 commit message 全程使用**中文**。

## 项目背景

LorisID 是一个 World of Warcraft Retail (12.0 Midnight) 插件，用于在鼠标悬停提示中显示法术/物品/NPC/宠物技能等游戏内部 ID。支持 10 种语言本地化。

## 关键文件结构

| 文件 | 职责 |
|------|------|
| `Init.lua` | 命名空间、ID 类型常量、默认配置 |
| `Core.lua` | 斜杠命令、战斗事件、性能监控 |
| `Settings.lua` | 设置面板 UI |
| `Modules/IDDisplay.lua` | Tooltip ID 注入引擎（三层权重钩子） |
| `Modules/AuraScanner.lua` | 光环扫描/CSV 导出 |
| `Localization.lua` | 5 种语言 (enUS/zhCN/zhTW/koKR/deDE) |
| `Localization2.lua` | 5 种语言 (frFR/esES/ruRU/ptBR/itIT) |
