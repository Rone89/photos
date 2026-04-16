#!/bin/bash

# PhotoManager iOS App IPA 打包脚本
# 使用方法：在 Mac 终端中运行此脚本
# 前提条件：已安装 Xcode 和命令行工具

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_NAME="PhotoManager"
SCHEME_NAME="PhotoManager"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/IPA"
EXPORT_OPTIONS_PLIST="${BUILD_DIR}/ExportOptions.plist"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  PhotoManager iOS App IPA 打包脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否在 Mac 上运行
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}错误：此脚本必须在 macOS 上运行${NC}"
    exit 1
fi

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}错误：未找到 xcodebuild，请安装 Xcode${NC}"
    exit 1
fi

# 检查项目文件是否存在
if [ ! -d "${PROJECT_NAME}.xcodeproj" ]; then
    echo -e "${RED}错误：未找到 ${PROJECT_NAME}.xcodeproj 项目文件${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 环境检查通过${NC}"
echo ""

# 清理旧的构建文件
echo -e "${YELLOW}清理旧的构建文件...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

# 创建 ExportOptions.plist
echo -e "${YELLOW}创建导出配置文件...${NC}"
cat > "${EXPORT_OPTIONS_PLIST}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string></string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.yourname.photomanager</key>
        <string>PhotoManager Development</string>
    </dict>
    <key>signingCertificate</key>
    <string>Apple Development</string>
</dict>
</plist>
EOF
echo -e "${GREEN}✓ 导出配置文件创建完成${NC}"
echo ""

# 显示可用的签名证书
echo -e "${YELLOW}可用的签名证书：${NC}"
security find-identity -v -p codesigning | grep "Apple Development\|iPhone Developer\|iPhone Distribution"
echo ""

# 提示用户输入团队 ID
echo -e "${YELLOW}请输入你的 Apple Developer Team ID（在 Apple Developer 网站可以找到）：${NC}"
read -r TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo -e "${RED}错误：Team ID 不能为空${NC}"
    exit 1
fi

# 更新 ExportOptions.plist 中的 Team ID
sed -i '' "s/<string><\/string>/<string>${TEAM_ID}<\/string>/" "${EXPORT_OPTIONS_PLIST}"

# 显示可用的设备
echo -e "${YELLOW}已连接的设备：${NC}"
xcrun xctrace list devices | grep -E "iPhone|iPad" | head -5
echo ""

# 提示用户选择签名方式
echo -e "${YELLOW}请选择签名方式：${NC}"
echo "1) 自动签名（推荐，使用 Xcode 自动管理）"
echo "2) 手动签名（需要指定 provisioning profile）"
read -r SIGNING_CHOICE

if [ "$SIGNING_CHOICE" = "1" ]; then
    # 自动签名
    echo -e "${YELLOW}使用自动签名模式构建...${NC}"
    
    # 构建 Archive
    echo -e "${YELLOW}正在构建 Archive...${NC}"
    xcodebuild archive \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -archivePath "${ARCHIVE_PATH}" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="${TEAM_ID}" \
        | xcpretty
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${RED}错误：Archive 构建失败${NC}"
        exit 1
    fi
    
    # 导出 IPA
    echo -e "${YELLOW}正在导出 IPA...${NC}"
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
        | xcpretty
        
else
    # 手动签名
    echo -e "${YELLOW}使用手动签名模式构建...${NC}"
    
    # 提示用户输入 provisioning profile 名称
    echo -e "${YELLOW}请输入 Provisioning Profile 名称：${NC}"
    read -r PROFILE_NAME
    
    if [ -z "$PROFILE_NAME" ]; then
        echo -e "${RED}错误：Provisioning Profile 名称不能为空${NC}"
        exit 1
    fi
    
    # 更新 ExportOptions.plist
    sed -i '' "s/PhotoManager Development/${PROFILE_NAME}/" "${EXPORT_OPTIONS_PLIST}"
    
    # 构建 Archive
    echo -e "${YELLOW}正在构建 Archive...${NC}"
    xcodebuild archive \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -archivePath "${ARCHIVE_PATH}" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Manual \
        PROVISIONING_PROFILE_SPECIFIER="${PROFILE_NAME}" \
        DEVELOPMENT_TEAM="${TEAM_ID}" \
        | xcpretty
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo -e "${RED}错误：Archive 构建失败${NC}"
        exit 1
    fi
    
    # 导出 IPA
    echo -e "${YELLOW}正在导出 IPA...${NC}"
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
        | xcpretty
fi

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}错误：IPA 导出失败${NC}"
    exit 1
fi

# 检查 IPA 文件是否生成
IPA_FILE=$(find "${EXPORT_PATH}" -name "*.ipa" | head -1)

if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}错误：未找到生成的 IPA 文件${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  打包成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}IPA 文件位置：${NC}"
echo -e "${BLUE}${IPA_FILE}${NC}"
echo ""
echo -e "${YELLOW}文件大小：${NC}$(du -h "$IPA_FILE" | cut -f1)"
echo ""

# 显示安装选项
echo -e "${YELLOW}安装选项：${NC}"
echo "1) 使用 Xcode 安装到连接的设备"
echo "2) 使用 ios-deploy 安装（需要先安装：brew install ios-deploy）"
echo "3) 使用 Apple Configurator 2 安装"
echo "4) 仅显示 IPA 文件路径"
read -r INSTALL_CHOICE

case $INSTALL_CHOICE in
    1)
        echo -e "${YELLOW}请在 Xcode 中打开 Window → Devices and Simulators${NC}"
        echo -e "${YELLOW}选择你的设备，点击 + 按钮添加 IPA 文件${NC}"
        ;;
    2)
        if command -v ios-deploy &> /dev/null; then
            echo -e "${YELLOW}正在安装到设备...${NC}"
            ios-deploy -b "$IPA_FILE"
        else
            echo -e "${RED}未安装 ios-deploy，请运行：brew install ios-deploy${NC}"
        fi
        ;;
    3)
        echo -e "${YELLOW}请打开 Apple Configurator 2，将 IPA 文件拖入设备${NC}"
        ;;
    4)
        echo -e "${GREEN}IPA 文件已保存到：${IPA_FILE}${NC}"
        ;;
    *)
        echo -e "${GREEN}IPA 文件已保存到：${IPA_FILE}${NC}"
        ;;
esac

echo ""
echo -e "${GREEN}打包完成！${NC}"