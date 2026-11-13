#!/bin/zsh
# KitePaste 打包脚本：编译 release 并组装 .app Bundle
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="KitePaste"
BUNDLE_ID="com.ciyuan.kitepaste"
VERSION="${1:-0.2.0}"
CONFIG="${2:-release}"
APP_DIR=".build/${CONFIG}/${APP_NAME}.app"
CONTENTS="$APP_DIR/Contents"

echo "==> 编译 release..."
swift build -c release

echo "==> 组装 Bundle..."
rm -rf "$APP_DIR"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"

# 主程序：GUI 应用（用 /bin/cp 避免用户 shell 别名干扰）
/bin/cp ".build/${CONFIG}/KitePasteApp" "$CONTENTS/MacOS/${APP_NAME}"
# 附带命令行工具
mkdir -p "$CONTENTS/Resources/cli"
/bin/cp ".build/${CONFIG}/KitePaste" "$CONTENTS/Resources/cli/kitepaste"

cat > "$CONTENTS/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
</dict>
</plist>
EOF

echo "==> Ad-hoc 签名（本机可运行，免开发者账号）..."
codesign --force --deep --sign - "$APP_DIR"

echo "==> 校验..."
codesign --verify --verbose "$APP_DIR" 2>&1 | tail -1

echo "✅ 打包完成: $APP_DIR (v${VERSION})"
