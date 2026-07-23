# P0：本地化加载与设置窗口体验

- Status: Implemented
- Last updated: 2026-07-23
- Owners: project maintainers

## 背景与目标

Swift Package 资源位于 `Bundle.module`，但 SwiftUI 默认从 `Bundle.main` 查找本地化，导致界面显示裸 key。设置窗口布局松散、Picker 截断、应用图标缺少回退。本轮修复用户第一眼可见的问题。

## 非目标

- 自定义输入源选择与映射（P1）。
- 配置导入导出、正式签名与公证（P2）。
- 高级规则条件与分组（P3）。

## 需求

- R1: 所有用户可见文案 MUST 通过统一 `L10n` 层从 `Bundle.module` 加载。
- R2: 英文与简体中文 key 集合 MUST 对称，解析结果 MUST 不等于 key 本身。
- R3: 设置窗口标题 MUST 显示 `Lingo`，不得显示本地化 key。
- R4: 规则列表 MUST 使用稳定列布局，输入法名称完整可读。
- R5: 应用图标 MUST 通过 Bundle ID 解析并缓存；未安装时显示 SF Symbol 回退并标记“应用未找到”。
- R6: 空列表与无搜索结果 MUST 使用不同文案。

## 验收场景

- A1 — Given 中文系统，When 打开设置，Then 不出现 `tab.rules` 等裸 key。
- A2 — Given 英文 locale，When 解析关键文案，Then 返回英文且不等于 key。
- A3 — Given 未安装应用的 Bundle ID，When 显示规则行，Then 显示回退图标与“应用未找到”。
- A4 — Given 搜索无匹配，When 规则列表为空，Then 显示“没有匹配的规则”而非“暂无规则”。

## 技术方案

- `Sources/Lingo/Support/Localization.swift` 提供 `L10n.string` 与格式化方法，固定 `Bundle.module`。
- SwiftUI 视图通过 `Text(l10n:)`、`Label(l10n:systemImage:)` 等扩展渲染文案。
- `ApplicationIconResolver` 封装 `NSWorkspace` 查询与内存缓存，注入 `ApplicationLookup` 便于测试。
- `SettingsView` 收紧默认/最小尺寸，规则行使用 menu 风格 Picker 与固定列宽。

## 测试计划

- `LocalizationTests`：key 对称性、中英文解析、格式化参数。
- `ApplicationIconResolverTests`：未安装回退、缓存命中、空 Bundle ID。
- `swift test` 与 `script/security_check.sh` 全绿。

## 实现映射

- R1-R3: `Localization.swift`, 各 View/Store/Service
- R4-R6: `SettingsView.swift`, `ApplicationIconResolver.swift`
- 测试: `LocalizationTests.swift`, `ApplicationIconResolverTests.swift`

## 验证结果

- 2026-07-23：`swift test` 14 项全绿；`script/security_check.sh` 通过。
- 自动化覆盖：`LocalizationTests`（key 对称、中英文解析、格式化）、`ApplicationIconResolverTests`（回退、缓存）。
- 手动检查（待完成）：浅色/深色截图验收、中英文系统实机确认。

## 手动检查

- [ ] 浅色/深色模式下设置窗口布局可读。
- [ ] 中英文系统下菜单栏、设置页、编辑弹窗文案正确。
- [ ] 已安装应用显示原始图标，未安装显示回退图标。
