# 照片管理 iOS 应用

一个用于管理和整理 iPhone 相册照片的 SwiftUI 应用，支持按月份浏览照片，通过手势快速标记保存或删除。

## 功能特性

- 📅 按月份自动分组显示照片
- 👆 手势操作：
  - 左滑：标记为保存并切换到下一张
  - 上滑：标记为删除并切换到下一张
  - 右滑：返回上一张照片
- 📊 月份总览：查看标记统计和照片列表
- 🗑️ 批量删除：快速删除所有标记为删除的照片
- 🔒 隐私安全：所有操作都在本地进行，照片不会上传到服务器

## 系统要求

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## 安装和运行

### 方法一：使用 Xcode

1. 打开 Xcode，选择 "Create a new project"
2. 选择 "iOS" → "App"
3. 设置产品名称为 "PhotoManager"，界面选择 "SwiftUI"，语言选择 "Swift"
4. 将 `PhotoManager` 文件夹中的所有 `.swift` 文件复制到新项目中
5. 替换默认的 `Info.plist` 文件为项目中的 `Info.plist`
6. 将 `Assets.xcassets` 文件夹复制到项目中
7. 连接 iPhone 设备或选择模拟器
8. 点击运行按钮 (⌘+R)

### 方法二：使用 Swift Package Manager

1. 克隆或下载此项目
2. 在终端中导航到项目目录
3. 运行以下命令：
   ```bash
   swift package init --type executable
   ```
4. 将源文件移动到 `Sources` 目录
5. 使用 `swift build` 构建项目

## 使用说明

### 首次使用

1. 启动应用后，系统会请求相册访问权限
2. 点击"允许"以授权应用访问相册
3. 应用会自动加载所有照片并按月份分组

### 浏览和标记照片

1. 在主界面选择要浏览的月份
2. 查看照片并使用手势标记：
   - **左滑**：标记为保存（绿色指示）
   - **上滑**：标记为删除（红色指示）
   - **右滑**：返回上一张照片
3. 浏览完所有照片后，会自动显示月份总览

### 查看总览和批量删除

1. 在照片浏览界面点击右上角的"总览"按钮
2. 查看标记统计：
   - 保存的照片数量
   - 待删除的照片数量
   - 未标记的照片数量
3. 点击"删除标记照片"按钮批量删除标记为删除的照片
4. 确认删除操作（此操作不可撤销）

## 项目结构

```
PhotoManager/
├── PhotoManagerApp.swift      # 应用入口点
├── ContentView.swift          # 主视图，包含月份列表
├── PhotoManagerViewModel.swift # 视图模型，处理数据逻辑
├── PhotoSwipeView.swift       # 照片滑动浏览视图
├── MonthOverviewView.swift    # 月份总览视图
├── Info.plist                 # 应用配置和权限描述
└── Assets.xcassets/           # 应用资源文件
```

## 技术栈

- **SwiftUI**: 声明式 UI 框架
- **PhotosUI**: 照片访问和管理
- **Combine**: 响应式编程
- **MVVM**: 架构模式

## 注意事项

1. **权限要求**：应用需要相册读取和删除权限
2. **存储空间**：删除照片会永久移除，请谨慎操作
3. **备份建议**：在删除照片前，建议先备份重要内容
4. **性能优化**：大量照片可能需要较长的加载时间

## 故障排除

### 应用无法访问照片

1. 检查设置中的相册权限：设置 → 隐私 → 照片
2. 确保已授权 PhotoManager 应用
3. 重启应用尝试重新加载

### 删除照片失败

1. 确保有足够的存储空间
2. 检查照片是否被其他应用占用
3. 尝试重新启动设备

### 应用崩溃

1. 确保 iOS 版本符合要求
2. 检查 Xcode 控制台错误信息
3. 尝试清理项目并重新构建：Product → Clean Build Folder

## 开发说明

### 添加新功能

1. 在 `PhotoManagerViewModel` 中添加数据逻辑
2. 创建新的 SwiftUI 视图
3. 更新导航和状态管理

### 自定义手势

可以在 `PhotoSwipeView.swift` 中修改手势识别逻辑：
- 调整 `horizontalThreshold` 和 `verticalThreshold` 改变手势灵敏度
- 添加新的手势类型（如下滑）
- 修改标记逻辑和动画效果

### 适配其他设备

1. 修改 `Info.plist` 中的方向支持
2. 调整布局约束和尺寸
3. 测试不同屏幕尺寸的显示效果

## 许可证

本项目仅供学习和个人使用。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue
- 发送邮件至开发者

---

## 📦 打包成 IPA 文件

### 快速打包（推荐）

1. **将项目复制到 Mac 电脑**
2. **打开终端，进入项目目录**
3. **运行快速打包脚本**：
   ```bash
   chmod +x quick_build.sh
   ./quick_build.sh
   ```
4. **按照提示输入**：
   - Apple Developer Team ID
   - Bundle Identifier（可选）
5. **等待打包完成**，IPA 文件会生成在 `build/IPA/` 目录

### 详细打包指南

查看 `BUILD_GUIDE.md` 文件，包含：
- 多种打包方法（Xcode 手动打包、自动化脚本）
- 签名配置详解
- 安装到 iPhone 的多种方式
- 常见问题解决方案

### 打包前提条件

- **macOS 电脑**（必须）
- **Xcode 15.0+** 已安装
- **Apple Developer 账号**（免费或付费）
- **iOS 设备**（用于测试）

### 签名说明

- **免费账号**：应用每 7 天需要重新签名
- **付费账号**（$99/年）：应用有效期 1 年，可分发给最多 100 台设备
- **企业账号**：适合内部分发，费用更高

### 安装到 iPhone

打包完成后，可以通过以下方式安装：

1. **Xcode 直接安装**（最简单）：
   - 连接 iPhone 到 Mac
   - 在 Xcode 中选择设备，点击运行

2. **使用 IPA 文件**：
   - 通过 Xcode 的 Devices 窗口安装
   - 使用 Apple Configurator 2
   - 使用 TestFlight 分发

3. **使用命令行**：
   ```bash
   # 安装 ios-deploy
   brew install ios-deploy
   
   # 安装 IPA
   ios-deploy -b /path/to/PhotoManager.ipa
   ```

### 故障排除

**打包失败？**
1. 检查 Team ID 是否正确
2. 确保 Bundle Identifier 唯一
3. 尝试使用自动签名
4. 清理项目：Xcode → Product → Clean Build Folder

**安装失败？**
1. 在 iPhone 上信任开发者证书：
   - 设置 → 通用 → VPN与设备管理 → 信任开发者证书
2. 检查设备 UDID 是否已添加到 Provisioning Profile
3. 确保设备 iOS 版本 ≥ 16.0

**应用闪退？**
1. 检查相册权限是否已授权
2. 查看 Xcode 控制台的错误信息
3. 确保 Info.plist 中的权限描述正确

---

**注意**: 本应用会删除照片，请在使用前确保已备份重要内容。