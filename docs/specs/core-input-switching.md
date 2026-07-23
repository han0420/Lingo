# 按应用自动切换输入法

- Status: Implemented
- Last updated: 2026-07-23
- Owners: project maintainers

## 背景与目标

Lingo 是 macOS 14+ 原生菜单栏应用。当前台应用变化时，根据 Bundle ID 对应规则自动选择中文或英文输入源；没有启用规则时使用全局默认值。

## 非目标

- 不按窗口、网页或输入框保存输入法。
- 不同步配置到云端。
- 首版不提供自定义任意输入源映射，使用中文/英文候选列表自动解析本机输入源。

## 用户行为

用户从设置窗口管理应用规则和全局选项。应用常驻菜单栏；关闭设置窗口不退出。总开关关闭或单条规则停用时保留配置但不按该规则切换。

## 需求

- R1: 前台应用 Bundle ID 变化时，应用 MUST 只触发一次规则解析。
- R2: 启用的精确 Bundle ID 规则 MUST 优先于全局默认输入法。
- R3: 停用的规则 MUST 视为不存在。
- R4: 自动切换总开关关闭时 MUST 不调用输入源服务。
- R5: 规则和全局设置 MUST 持久化，损坏数据 MUST 回退安全默认值。
- R6: 中文依次尝试搜狗拼音、系统简体拼音；英文依次尝试 ABC、US。
- R7: 用户 MUST 能新增、编辑、删除、搜索和启停规则。
- R8: 应用 MUST 提供菜单栏开关、设置入口、退出入口以及可选切换通知。
- R9: 应用 MUST 支持开机启动设置。

## 合法性与边界

Bundle ID 和应用名去除首尾空白后不能为空；同一 Bundle ID 只保留一条规则。首次启动提供微信、Safari、Chrome、VS Code、Cursor 预设。输入源不可用时不更改当前输入法，并向 UI 暴露错误状态。

## 验收场景

- A1 — Given 微信规则启用且为中文，When 微信成为前台应用，Then 选择可用的中文输入源。
- A2 — Given 规则停用，When 对应应用成为前台，Then 选择全局默认输入法。
- A3 — Given 总开关关闭，When 前台应用变化，Then 不选择任何输入源。
- A4 — Given 设置已保存，When 重新创建配置存储，Then 恢复相同设置和规则。
- A5 — Given 用户点击某条规则的删除按钮，When 在确认提示中选择删除，Then 仅移除该规则并保存其余配置。

## 技术方案

`NSWorkspace.didActivateApplicationNotification` 提供事件驱动的前台应用监听。`InputSourceService` 封装 Carbon TIS API，`LingoStore` 负责规则决策、持久化和副作用编排，SwiftUI 只呈现状态和发送用户意图。配置保存在 `UserDefaults`，登录项使用 `ServiceManagement`。

## 测试计划

XCTest 覆盖规则优先级、停用规则、总开关、去重和持久化；`swift test` 编译完整 App target。菜单栏、真实输入源切换、通知权限与登录项需要手动验证。

## 实现映射

- R1-R4: `WorkspaceMonitor.swift`, `RuleResolver`, `LingoStore.swift`
- R5: `ConfigurationRepository.swift`, `ConfigurationTests.swift`
- R6: `InputSourceService.swift`
- R7-R9: `SettingsView.swift`, `RuleEditorView.swift`, `LingoStore.swift`, `LingoApp.swift` 及系统服务
- 自动化验证：`RuleResolverTests.swift`, `ConfigurationTests.swift`, `LingoStoreTests.swift`

## 验证结果

- `swift test`: 7 tests passed
- `script/security_check.sh`: passed
- debug app assembly and ad-hoc signature verification: passed
- `script/build_and_run.sh --verify`: passed
- 手动待验：分别切换到一个中文规则应用和英文规则应用；通知授权后的提示；登录项在下次登录时启动。

## 未决问题

无。
