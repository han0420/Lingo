# P1：输入源发现与用户配置

- Status: Implemented
- Last updated: 2026-07-23
- Owners: project maintainers

## 背景与目标

当前 `InputSourceService` 仅按固定候选 Source ID 切换，用户无法选择第三方中文输入法，也无法分别配置中英文输入源。需要枚举本机可选键盘输入源，并允许用户分别指定。

## 非目标

- 不为每条规则单独映射任意 Source ID（规则仍使用中文/英文语义）。
- 不记录输入源使用历史。

## 需求

- R1: 应用 MUST 枚举本机可选择的键盘输入源，包含显示名称与 Source ID。
- R2: 用户 MUST 能分别配置“中文输入源”和“英文输入源”。
- R3: 切换时 MUST 优先使用用户配置的 Source ID；不可用时回退到旧版候选顺序。
- R4: 配置中保存的 Source ID 不可用时 MUST 保持当前输入法，并展示可行动错误。
- R5: 旧版配置（无输入源字段）升级后 MUST 保留规则并自动迁移默认输入源。

## 技术方案

- `InputSourceDescriptor` 描述可选输入源。
- `InputSourceCatalog` 封装 Carbon TIS 枚举与按 ID 选择。
- `InputSourcePreferenceResolver` 纯函数解析中文/英文 Source ID。
- `LingoConfiguration` 增加 `chineseInputSourceID`、`englishInputSourceID` 可选字段。
- 设置页“通用”分区增加两个 Picker。

## 测试计划

- 偏好解析：配置优先、旧候选回退、无可用源返回 nil。
- 配置迁移：旧 JSON 无新字段时可加载并补全。
- `swift test` 全绿。

## 验证结果

- 2026-07-23：`swift test` 24 项全绿；`script/security_check.sh` 通过。
- 自动化覆盖：`InputSourcePreferenceResolverTests`、`ConfigurationMigrationTests`、`LingoStoreTests`（mock 输入源）。

## 手动检查

- R1-R3: `InputSourceCatalog.swift`, `InputSourcePreferenceResolver.swift`
- R4-R5: `LingoStore.swift`, `ConfigurationRepository.swift`, `SettingsView.swift`
- 测试: `InputSourcePreferenceResolverTests.swift`, `ConfigurationMigrationTests.swift`
