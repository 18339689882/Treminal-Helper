# Terminal Helper

<p align="center">
  <img src="Terminal Helper/Assets.xcassets/AppIcon.appiconset/icon-256.png" alt="Terminal Helper Icon" width="128" height="128">
</p>

<p align="center">
  <strong>快速在 Finder 中执行终端命令的 macOS 开发者工具</strong>
</p>

<p align="center">
  <a href="https://github.com/你的用户名/Terminal-Helper/releases/latest">
    <img src="https://img.shields.io/github/v/release/你的用户名/Terminal-Helper?label=最新版本" alt="Latest Release">
  </a>
  <a href="https://github.com/你的用户名/Terminal-Helper/releases">
    <img src="https://img.shields.io/github/downloads/你的用户名/Terminal-Helper/total?label=下载量" alt="Downloads">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/你的用户名/Terminal-Helper?label=许可证" alt="License">
  </a>
  <img src="https://img.shields.io/badge/macOS-11.0+-blue" alt="macOS 11.0+">
</p>

---

## ✨ 功能特性

- 🖱️ **Finder 右键菜单集成** - 在任意文件夹右键即可执行预设命令
- ⌨️ **菜单栏快捷访问** - 通过菜单栏图标快速执行常用命令  
- 🎯 **自定义命令管理** - 自由添加和管理你的常用终端命令
- 🚀 **智能路径定位** - 自动定位到当前 Finder 路径执行命令
- 🎨 **简洁易用** - 极简设计，开箱即用，无需复杂配置

## 📸 应用截图

### 菜单栏快捷访问
<p align="center">
  <img src="screenshots/menubar.png" alt="菜单栏" width="300">
</p>

### Finder 右键菜单
<p align="center">
  <img src="screenshots/finder-menu.png" alt="右键菜单" width="600">
</p>

### 命令管理界面
<p align="center">
  <img src="screenshots/settings.png" alt="设置界面" width="700">
</p>

## 📥 下载安装

### 直接下载

**[👉 点击下载最新版本](https://github.com/你的用户名/Terminal-Helper/releases/latest)**

选择以下任一格式：
- `Terminal-Helper-v1.0.0.dmg` - DMG 安装包（推荐）
- `Terminal-Helper-v1.0.0.zip` - ZIP 压缩包

### 系统要求

- macOS 11.0 或更高版本
- Apple Silicon (M系列) 或 Intel 处理器

### 安装步骤

#### 方法 1：使用 DMG（推荐）

1. 下载 `Terminal-Helper-v1.0.0.dmg`
2. 双击打开 DMG 文件
3. 将 **Terminal Helper.app** 拖到 **应用程序** 文件夹
4. 在应用程序文件夹中双击启动

#### 方法 2：使用 ZIP

1. 下载 `Terminal-Helper-v1.0.0.zip`
2. 解压缩得到 **Terminal Helper.app**
3. 将应用拖到 **应用程序** 文件夹
4. 双击启动

### ⚠️ 首次运行

首次打开时，macOS 可能会显示安全提示：

<p align="center">
  <img src="screenshots/security-prompt.png" alt="安全提示" width="400">
</p>

**解决方法 1：** 点击 **打开** 按钮

**解决方法 2：** 如果显示"应用已损坏"，在终端中运行：
```bash
xattr -cr /Applications/Terminal\ Helper.app
```

然后重新启动应用。

## ⚙️ 设置权限

Terminal Helper 需要以下权限才能正常工作：

### 1. 自动化权限

允许控制终端和访达：

1. 打开 **系统设置**（System Settings）
2. 进入 **隐私与安全性** → **自动化**（Privacy & Security → Automation）
3. 找到 **Terminal Helper**
4. 勾选以下选项：
   - ✅ **终端**（Terminal）
   - ✅ **访达**（Finder）

<p align="center">
  <img src="screenshots/automation-permission.png" alt="自动化权限" width="500">
</p>

### 2. Finder 扩展

启用 Finder 右键菜单集成：

1. 打开 **系统设置**
2. 进入 **隐私与安全性** → **扩展** → **Finder 扩展**
3. 勾选 **Terminal Helper Extension** ✅

<p align="center">
  <img src="screenshots/finder-extension.png" alt="Finder扩展" width="500">
</p>

## 🎯 使用指南

### 方式 1：Finder 右键菜单（推荐）

1. 在 Finder 中右键点击任意 **文件夹**
2. 在菜单中找到 **Terminal Helper Extension**
3. 选择要执行的命令
4. Terminal 会自动打开并在该目录执行命令

<p align="center">
  <img src="screenshots/usage-finder.gif" alt="Finder使用演示" width="600">
</p>

### 方式 2：菜单栏快捷访问

1. 点击菜单栏的 **Terminal Helper 图标**（终端符号 ⌘）
2. 从下拉菜单中选择命令
3. 命令会在当前 Finder 窗口路径执行
4. 如果没有打开 Finder 窗口，会在用户主目录执行

<p align="center">
  <img src="screenshots/usage-menubar.gif" alt="菜单栏使用演示" width="400">
</p>

### 添加自定义命令

1. 点击菜单栏图标 → **偏好设置**（Preferences）
2. 点击 **添加**（Add）按钮
3. 填写命令信息：
   - **命令名称**：例如 "Git Status"
   - **命令字符串**：例如 "git status"
4. 点击 **保存**（Save）

### 常用命令示例

- **Git 状态**：`git status`
- **在 VS Code 中打开**：`code .`
- **npm 安装**：`npm install`
- **Python 虚拟环境**：`python3 -m venv venv && source venv/bin/activate`
- **查看磁盘使用**：`du -sh *`

## 🛠️ 开发构建

### 克隆项目

```bash
git clone https://github.com/你的用户名/Terminal-Helper.git
cd Terminal-Helper
```

### 在 Xcode 中打开

```bash
open "Terminal Helper.xcodeproj"
```

### 构建项目

1. 选择 **Terminal Helper** scheme
2. 选择目标设备（My Mac）
3. 按 `Cmd + B` 构建
4. 按 `Cmd + R` 运行

### 技术栈

- **语言**：Objective-C
- **框架**：
  - Cocoa (macOS UI)
  - FinderSync (Finder 扩展)
  - App Groups (进程间通信)
  - NSAppleScript (Terminal 集成)
- **架构**：
  - 主应用（菜单栏 + 设置界面）
  - Finder Extension（右键菜单）
  - 共享框架（命令管理）

### 项目结构

```
Terminal-Helper/
├── Terminal Helper/          # 主应用
│   ├── AppDelegate.m         # 应用启动和菜单栏
│   ├── THSettingsViewController.m  # 设置界面
│   └── Assets.xcassets/      # 图标资源
├── THFinderExtension/        # Finder 扩展
│   └── FinderSync.m          # 右键菜单实现
├── THShared/                 # 共享代码
│   ├── THCommandManager.m    # 命令管理器
│   ├── THCommand.m           # 命令模型
│   └── THConstants.m         # 常量定义
└── README.md
```

## 📝 更新日志

### v1.0.0 (2026-08-09)

- 🎉 首次发布
- ✨ 支持 Finder 右键菜单集成
- ✨ 支持菜单栏快捷访问
- ✨ 支持自定义命令管理
- ✨ 预设"在此处打开终端"命令
- ✨ 智能路径定位
- 🐛 修复 Terminal 命令执行问题
- 🐛 修复双窗口打开问题

查看 [完整更新历史](https://github.com/你的用户名/Terminal-Helper/releases)

## 🐛 已知问题

- 首次使用需要手动授予自动化权限（系统限制）
- 某些命令可能需要 sudo 权限，建议谨慎使用
- 在某些 macOS 版本中，Finder 扩展可能需要重启 Finder 才能生效

### 常见问题解决

**Q: 右键菜单中没有看到 Terminal Helper？**

A: 
1. 检查系统设置中是否启用了 Finder 扩展
2. 重启 Finder：按住 `Option` 键右键点击 Finder 图标 → 重新启动
3. 重启电脑

**Q: 命令执行失败？**

A: 检查系统设置 → 隐私与安全性 → 自动化，确保已授权控制终端和访达

**Q: 应用无法打开，提示"已损坏"？**

A: 运行以下命令移除隔离属性：
```bash
xattr -cr /Applications/Terminal\ Helper.app
```

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循现有代码风格
- 添加必要的注释
- 更新相关文档

## 📄 开源许可

本项目采用 **MIT 许可证**。详见 [LICENSE](LICENSE) 文件。

简单来说：
- ✅ 可以自由使用
- ✅ 可以修改代码
- ✅ 可以商业使用
- ✅ 需要保留版权声明

## 📞 联系方式

- 💬 **问题反馈**：[GitHub Issues](https://github.com/你的用户名/Terminal-Helper/issues)
- 📧 **邮箱**：1275659412@qq.com
- 🌟 **项目主页**：[GitHub Repository](https://github.com/你的用户名/Terminal-Helper)

## 💖 致谢

感谢所有使用和支持 Terminal Helper 的朋友！

如果这个工具对你有帮助，请考虑：
- ⭐️ 给项目一个 Star
- 🐛 报告 Bug 或提出建议
- 📢 分享给更多开发者

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/你的用户名">@你的用户名</a>
</p>

<p align="center">
  <a href="#terminal-helper">回到顶部 ↑</a>
</p>
