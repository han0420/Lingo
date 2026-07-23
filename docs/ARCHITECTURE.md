# Lingo 架构

## 数据流

```text
NSWorkspace 前台应用事件 → LingoStore → RuleResolver → InputSourceService → Carbon TIS API
                              │              │
                              │              └─ 启用规则优先，否则全局默认
                              ├─ ConfigurationRepository (UserDefaults)
                              ├─ LoginItemService (ServiceManagement)
                              └─ SwitchNotificationService (UserNotifications)
```

`LingoStore` 是唯一状态编排点。SwiftUI 视图不直接访问 Carbon、`UserDefaults` 或系统事件；`RuleResolver` 是无系统依赖的纯策略层。

## 目录职责

| 路径 | 职责 |
| --- | --- |
| `Sources/Lingo/App` | 应用生命周期和菜单栏入口 |
| `Sources/Lingo/Models` | 输入法、规则、持久化配置 |
| `Sources/Lingo/Services` | Carbon、前台应用、通知、登录项和存储适配器 |
| `Sources/Lingo/Stores` | 状态、规则决策和副作用编排 |
| `Sources/Lingo/Views` | 规则管理与全局设置 SwiftUI |
| `Sources/Lingo/Support` | 本地化访问、应用图标解析、设置窗口呈现、系统应用选择 |
| `Tests/LingoTests` | 领域策略和持久化测试 |

## 系统边界

输入源通过 Carbon TIS API 枚举与选择。`InputSourcePreferenceResolver` 将规则中的中文/英文语义映射到用户配置的 Source ID；未配置时回退搜狗拼音、系统简体拼音、ABC、US 候选顺序。找不到候选时保留当前输入法并记录用户可见错误。
