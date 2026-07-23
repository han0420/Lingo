# P1：品牌图片与菜单栏状态图

- Status: Implemented
- Last updated: 2026-07-23

## 目标

- 以“键盘 + 中字标识 + 环形切换箭头”为 Lingo 的统一品牌图形。
- App Icon 在 Dock、Finder 与应用包中保持清晰，并提供 macOS 所需的完整 iconset。
- 菜单栏状态图在浅色、深色与高对比度外观中自动适配。
- 中文、英文、切换中、已暂停、规则生效和全局关闭具有可辨识的独立图形。

## 非目标

- 不改变输入法切换策略、状态机或设置界面交互。
- 不引入联网品牌资源、遥测或运行时下载。

## 验收

- `AppIcon.icns` 由 1024×1024 品牌主图生成，iconset 包含标准与 Retina 尺寸（最高为 `icon_512x512@2x.png`）。
- 菜单栏使用 18×18 point 的 SF Symbols Template Image：常态为键盘加极小省略号徽记，切换中与关闭使用各自状态符号。
- App Icon 画布的四角透明，保留内部白色圆角图标本体及阴影。
- 所有 `MenuBarIconState` 都能解析到非空、22×22 point 的模板图。
- 品牌资源可通过 `script/generate_brand_assets.py` 确定性重新生成。

## 测试

- `MenuBarIconProviderTests` 验证各运行状态的尺寸和模板渲染属性。
- `swift test`
- `./script/security_check.sh`
- `./script/build_and_run.sh --verify`

## 手动检查

- 在浅色与深色菜单栏中逐一观察中文、英文、切换、规则生效和关闭状态。
- 在 Dock 与 Finder 中检查 16、32、128、256、512 point 下的 App Icon。

## 实现映射

- `Sources/Lingo/Resources/Brand/brand-master.png`：应用图标主品牌图。
- `script/generate_brand_assets.py`：为 App Icon 保留圆角本体、移除外层画布 alpha，并确定性生成 iconset 与 icns。
- `MenuBarIconProvider.swift`：以 18 point SF Symbols 提供清晰的菜单栏状态 Template Image。
- `MenuBarIconProviderTests.swift`：覆盖所有运行时状态的尺寸和模板属性。
