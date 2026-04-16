# PhotoManager iOS App 打包指南

## 📋 前提条件

1. **macOS 电脑**（必须）
2. **Xcode 15.0+** 已安装
3. **Apple Developer 账号**（免费或付费均可）
4. **iOS 设备**（用于测试安装）

## 🚀 快速打包（推荐）

### 方法一：使用自动化脚本（最简单）

1. **将项目复制到 Mac**：
   ```bash
   # 将 ios-photo-manager 文件夹复制到 Mac
   # 或者使用 Git 克隆
   ```

2. **打开终端，进入项目目录**：
   ```bash
   cd /path/to/ios-photo-manager
   ```

3. **赋予脚本执行权限**：
   ```bash
   chmod +x build_ipa.sh
   ```

4. **运行打包脚本**：
   ```bash
   ./build_ipa.sh
   ```

5. **按照提示操作**：
   - 输入你的 Apple Developer Team ID
   - 选择签名方式（自动签名推荐）
   - 等待打包完成

6. **获取 IPA 文件**：
   - 脚本会显示 IPA 文件位置
   - 通常在 `build/IPA/` 目录下

### 方法二：使用 Xcode 手动打包

1. **打开项目**：
   - 双击 `PhotoManager.xcodeproj` 文件
   - 或者在 Xcode 中选择 "Open a project or file"

2. **配置签名**：
   - 点击项目名称（左侧项目导航器）
   - 选择 "Signing & Capabilities"
   - 选择你的 Team
   - 修改 Bundle Identifier 为唯一值（如 `com.你的名字.photomanager`）

3. **选择目标设备**：
   - 在 Xcode 顶部选择 "Any iOS Device (arm64)"

4. **创建 Archive**：
   - 菜单栏选择 Product → Archive
   - 等待构建完成

5. **导出 IPA**：
   - 在 Organizer 窗口中选择刚创建的 Archive
   - 点击 "Distribute App"
   - 选择 "Development"（用于测试）
   - 按照向导完成导出

## 📱 安装到 iPhone

### 方法一：使用 Xcode 安装（最简单）

1. **连接 iPhone 到 Mac**
2. **在 iPhone 上信任电脑**：
   - 首次连接会弹出提示，点击"信任"
3. **在 Xcode 中安装**：
   - 选择你的 iPhone 作为运行目标
   - 点击运行按钮 (⌘+R)
   - 应用会自动安装到 iPhone

### 方法二：使用 IPA 文件安装

1. **使用 Xcode**：
   - 打开 Window → Devices and Simulators
   - 选择你的设备
   - 点击 + 按钮，选择 IPA 文件

2. **使用 Apple Configurator 2**：
   - 从 Mac App Store 下载 Apple Configurator 2
   - 连接设备
   - 将 IPA 文件拖入设备

3. **使用 ios-deploy**（命令行）：
   ```bash
   # 安装 ios-deploy
   brew install ios-deploy
   
   # 安装 IPA
   ios-deploy -b /path/to/PhotoManager.ipa
   ```

## 🔧 常见问题

### 1. 签名错误

**问题**：`Code signing error` 或 `Provisioning profile error`

**解决**：
- 确保 Bundle Identifier 唯一
- 检查 Team ID 是否正确
- 尝试使用自动签名
- 在 Xcode 中删除旧的 Provisioning Profile：
  - Xcode → Settings → Accounts → 选择你的账号 → Download Manual Profiles

### 2. 设备未识别

**问题**：iPhone 未出现在设备列表中

**解决**：
- 确保使用原装数据线
- 在 iPhone 上点击"信任此电脑"
- 重启 Xcode 和 iPhone
- 检查 Xcode 是否支持你的 iOS 版本

### 3. 应用无法安装

**问题**：`Unable to install` 或 `Application verification failed`

**解决**：
- 在 iPhone 上信任开发者证书：
  - 设置 → 通用 → VPN与设备管理 → 信任你的开发者证书
- 检查设备 UDID 是否已添加到 Provisioning Profile
- 确保设备 iOS 版本 ≥ 16.0

### 4. 应用闪退

**问题**：应用安装后无法打开

**解决**：
- 检查 Info.plist 中的权限描述是否正确
- 确保已添加相册访问权限：
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>需要访问相册以管理和整理照片</string>
  ```
- 在 iPhone 上允许相册访问权限

## 📦 打包配置说明

### Bundle Identifier
- 必须唯一，格式：`com.你的域名.应用名`
- 例如：`com.johnsmith.photomanager`

### 版本号
- `MARKETING_VERSION`：用户可见的版本号（如 1.0.0）
- `CURRENT_PROJECT_VERSION`：构建号（每次打包递增）

### 签名证书
- **Development**：用于开发和测试
- **Distribution**：用于 App Store 或 TestFlight
- **Ad Hoc**：用于指定设备的测试分发

### 设备支持
- 支持 iPhone 和 iPad
- 最低支持 iOS 16.0
- 针对 iPhone Air 优化（现代 iPhone 屏幕）

## 🎯 下一步

打包完成后，你可以：

1. **测试应用**：在 iPhone 上测试所有功能
2. **分发测试**：使用 TestFlight 分发给其他测试者
3. **提交审核**：准备提交到 App Store（需要付费开发者账号）

## 📞 获取帮助

如果遇到问题：

1. 检查 Xcode 控制台的错误信息
2. 确保所有权限配置正确
3. 参考 Apple 官方文档：
   - [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
   - [Code Signing](https://developer.apple.com/support/code-signing/)

## 📝 注意事项

- **免费账号**：应用每 7 天需要重新签名
- **付费账号**：$99/年，应用有效期 1 年
- **隐私政策**：如果提交到 App Store，需要提供隐私政策 URL
- **应用图标**：当前使用默认图标，建议替换为自定义图标

---

**祝打包顺利！** 🎉