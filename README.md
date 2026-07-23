# Lingo

Lingo 是一个 macOS 14+ 原生菜单栏应用：当前台应用发生变化时，自动切换到为该应用配置的中文或英文输入法。

## 已实现

- 基于 `NSWorkspace` 事件监听前台应用，无轮询、无 AppleScript
- 通过 Carbon TIS API 枚举并切换输入源；用户可在设置中分别指定中英文 Source ID，旧配置自动迁移
- 应用规则的新增、编辑、删除、搜索、启停和已安装 App 选择
- 全局默认输入法、总开关、切换通知和开机启动
- 微信、Safari、Chrome、VS Code、Cursor 默认规则
- 应用内语言切换（简体中文 / English）与登录后自动启动
- 原生菜单栏状态图标（中/英/切换/规则/关闭）与 App Icon（`script/generate_brand_assets.py` 从品牌稿生成）

## 开发

```bash
swift test
./script/build_and_run.sh
```

应用包生成到 `dist/Lingo.app`。本地调试可使用 ad-hoc 签名；公开分发仍需 Developer ID 签名、公证和发布流程。

## 隐私

配置只保存在本机 `UserDefaults`。Lingo 不上传应用使用情况，不含遥测或远程服务。前台应用监听使用 macOS Workspace 通知，不需要辅助功能权限。
