# P1：前台应用重新同步

- Status: Implemented
- Last updated: 2026-07-23

## 背景

`NSWorkspace.didActivateApplicationNotification` 在启动、睡眠唤醒、关闭 Lingo 设置窗口等场景下可能不触发，导致输入法未按当前前台应用规则切换。

## 需求

- R1: Lingo 启动监听后 MUST 立即读取当前前台应用并尝试切换。
- R2: 系统从睡眠唤醒后 MUST 重新读取前台应用并尝试切换。
- R3: 设置窗口关闭后 MUST 重新读取前台应用并尝试切换。
- R4: 重新同步时 MUST 允许与上次记录相同的前台 Bundle ID 再次切换。
- R5: 重新同步仍 MUST 跳过 Lingo 自身与自动切换关闭状态。

## 非目标

- 不引入轮询或 AppleScript。
- 不改变正常应用切换时的去重逻辑。

## 验收场景

- A1 — Given 用户已在微信且 Lingo 刚启动，When `start()` 完成，Then 切换到微信对应输入法。
- A2 — Given 用户从睡眠唤醒且前台应用未变化，When 唤醒通知到达，Then 仍按当前前台应用切换。
- A3 — Given 用户从 Lingo 设置返回原应用且系统未发送激活通知，When 设置窗口关闭，Then 仍按当前前台应用切换。
- A4 — Given 正常重复激活同一应用，When 收到 `didActivateApplicationNotification`，Then 仍跳过去重。

## 实现映射

- `SwitchCoordinator.swift`：`ignoreSameForegroundApplication` 参数
- `WorkspaceMonitor.swift`：启动同步与唤醒监听
- `LingoStore.swift`：`ForegroundActivationTrigger`、`resyncForegroundApplication()`
- `SettingsWindowLifecycle.swift`：设置窗口关闭回调
- `SwitchCoordinatorTests.swift`、`LingoStoreTests.swift`

## 验证结果

- 2026-07-23：`swift test` 40 项全绿；`script/security_check.sh` 通过；`script/build_and_run.sh --verify` 通过。
