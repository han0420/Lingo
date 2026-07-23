# Lingo UI 规范

- 设置窗口使用 `TabView` 区分“应用规则”和“通用设置”。通用设置使用 grouped `Form` + `Section`。
- 规则行始终展示应用图标、应用名、Bundle ID、输入法、启用开关和编辑入口。
- 主要新增/保存动作使用 `.borderedProminent`；删除使用系统 List 删除语义。
- 文本输入只编辑 sheet 内局部状态，点击保存后再进入 Store 和持久化层。
- 状态成功用绿色，错误用橙色；辅助说明使用 caption + secondary。
- 所有文案（含 placeholder、help、状态和错误）同步加入英文与简体中文资源。
