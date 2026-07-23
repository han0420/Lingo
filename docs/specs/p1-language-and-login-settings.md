# P1：应用内语言与登录启动设置

- Status: Implemented
- Last updated: 2026-07-23

## 目标

- 用户在设置「常规」中通过分段控件切换简体中文/English，无需改系统语言。
- 「登录后自动启动」提供标题、说明与开关，风格参考 QuotaPulse 常规设置。
- 「系统状态」展示自动切换启用/关闭状态。

## 需求

- R1: `preferredLanguage` 持久化到 `LingoConfiguration`。
- R2: `L10n` 使用应用内语言而非仅 `Locale.current`。
- R3: 切换语言后设置页与菜单栏文案立即刷新。
- R4: 登录启动复用 `LoginItemService`，UI 含说明文字。

## 实现映射

- `AppLanguage`, `LanguageSettings`, `LingoConfiguration`, `LingoStore`
- `SettingsView` 常规分区 UI
- `LanguageSettingsTests.swift`
