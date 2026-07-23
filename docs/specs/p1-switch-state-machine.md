# P1：切换状态机强化

- Status: Implemented
- Last updated: 2026-07-23

## 需求

- 总开关关闭、重复前台应用、Lingo 自身前台时跳过切换。
- 快速切换时使用序号防止过期结果覆盖。
- 内存记录最近一次成功切换（应用、输入源、原因、时间）。
- 区分规则命中与全局默认，并分别展示状态文案。

## 实现映射

- `SwitchCoordinator.swift`：纯策略与跳过判断
- `LingoStore.swift`：序号保护、`SwitchRecord`、`menuBarIconState`
- `SwitchCoordinatorTests.swift`、`LingoStoreTests.swift`

## 验证结果

- 2026-07-23：`swift test` 31 项全绿。
