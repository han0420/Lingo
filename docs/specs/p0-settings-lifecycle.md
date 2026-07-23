# P0：设置窗口生命周期与入口

- Status: Implemented
- Last updated: 2026-07-23
- Owners: project maintainers

## 背景与目标

菜单栏应用需要可预期的设置入口：不强制首次弹窗、复用同一设置窗口、关闭窗口后后台驻留、菜单栏与设置页状态同步。

## 产品决策

- **首次启动不自动打开设置窗口。** 菜单栏工具类应用遵循 macOS 惯例，首次启动仅驻留菜单栏，由用户主动打开设置。
- 使用 SwiftUI `Settings` scene 作为唯一设置窗口来源，避免手动创建重复 `WindowGroup`。

## 需求

- R1: 首次启动 MUST NOT 自动弹出设置窗口。
- R2: 菜单栏“设置” MUST 激活已有设置窗口并将其置于前台。
- R3: 关闭设置窗口后应用 MUST 继续运行。
- R4: 菜单栏总开关与设置页 Toggle MUST 共享同一 `LingoStore` 状态并实时同步。

## 技术方案

- `SettingsWindowPresenter` 封装 `NSApp.activate` + `openSettings()` + 已有窗口 `makeKeyAndOrderFront`。
- `LingoStoreTests` 覆盖总开关写入与重复前台应用跳过切换。

## 实现映射

- R1-R3: `LingoApp.swift`, `SettingsWindowPresenter.swift`
- R4: `LingoStore.swift`, `LingoStoreTests.swift`
