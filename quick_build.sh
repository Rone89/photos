#!/bin/bash

# PhotoManager 快速打包脚本（简化版）
# 适用于已有开发者证书的用户

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  PhotoManager 快速打包脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否在 Mac 上运行
if [[ "$(uname)" != "Darwin" ]]; then
    echo "错误：此脚本必须在 macOS 上运行"
    exit 1
fi

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "错误：未找到 xcodebuild，请安装 Xcode"
    exit 1
fi

# 清理构建目录
echo -e "${YELLOW}清理构建目录...${NC}"
rm -rf build
mkdir -p build

# 获取 Team ID
echo -e "${YELLOW}请输入你的 Apple Developer Team ID：${NC}"
read -r TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo "错误：Team ID 不能为空"
    exit 1
fi

# 获取 Bundle Identifier
echo -e "${YELLOW}请输入 Bundle Identifier（默认：com.yourname.photomanager）：${NC}"
read -r BUNDLE_ID
BUNDLE_ID=${BUNDLE_ID:-com.yourname.photomanager}

# 更新项目配置
echo -e "${YELLOW}更新项目配置...${NC}"
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com.yourname.photomanager/PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID}/" PhotoManager.xcodeproj/project.pbxproj
sed -i '' "s/DEVELOPMENT_TEAM = /DEVELOPMENT_TEAM = ${TEAM_ID}/" PhotoManager.xcodeproj/project.pbxproj

# 创建 ExportOptions.plist
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# 构建 Archive
echo -e "${YELLOW}正在构建 Archive...${NC}"
xcodebuild archive \
    -project PhotoManager.xcodeproj \
    -scheme PhotoManager \
    -configuration Release \
    -archivePath build/PhotoManager.xcarchive \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="${TEAM_ID}" \
    PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}"

# 导出 IPA
echo -e "${YELLOW}正在导出 IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath build/PhotoManager.xcarchive \
    -exportPath build/IPA \
    -exportOptionsPlist build/ExportOptions.plist

# 检查 IPA 文件
IPA_FILE=$(find build/IPA -name "*.ipa" | head -1)

if [ -z "$IPA_FILE" ]; then
    echo "错误：未找到生成的 IPA 文件"
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

# 安装选项
echo -e "${YELLOW}是否立即安装到连接的设备？(y/n)${NC}"
read -r INSTALL

if [ "$INSTALL" = "y" ] || [ "$INSTALL" = "Y" ]; then
    # 检查连接的设备
    DEVICE=$(xcrun xctrace list devices | grep -E "iPhone|iPad" | grep -v "Simulator" | head -1 | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
    
    if [ -z "$DEVICE" ]; then
        echo "未找到连接的设备，请手动安装"
    else
        echo -e "${YELLOW}找到设备：${DEVICE}${NC}"
        echo -e "${YELLOW}正在安装...${NC}"
        
        # 使用 xcodebuild 安装
        xcodebuild -project PhotoManager.xcodeproj \
            -scheme PhotoManager \
            -destination "id=${DEVICE}" \
            -configuration Release \
            CODE_SIGN_STYLE=Automatic \
            DEVELOPMENT_TEAM="${TEAM_ID}" \
            PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}" \
            install
    fi
fi

echo ""
echo -e "${GREEN}完成！${NC}"