#!/bin/zsh
# 生成带「拖入 Applications」安装界面的 DMG
set -euo pipefail
cd "$(dirname "$0")/.."

APP="KitePaste.app"
VERSION="${1:-0.2.0}"
VOLNAME="KitePaste"
RW=".build/KitePaste-rw.dmg"
OUT=".build/KitePaste-v${VERSION}-macos.dmg"

[[ -d ".build/release/${APP}" ]] || ./scripts/package.sh "$VERSION"

echo "==> 清理可能的残留挂载..."
for vol in /Volumes/KitePaste*(N); do
    hdiutil detach "$vol" -quiet || true
done

echo "==> 创建可写 DMG..."
/bin/rm -f "$RW"
hdiutil create -size 16m -fs HFS+ -volname "$VOLNAME" -layout NONE -type UDIF -attach "$RW" >/dev/null

echo "==> 放入应用与 Applications 替身..."
/usr/bin/ditto ".build/release/${APP}" "/Volumes/${VOLNAME}/${APP}"
/bin/ln -s /Applications "/Volumes/${VOLNAME}/Applications"

echo "==> 设置安装窗口布局..."
osascript <<'APPLESCRIPT'
tell application "Finder"
    set theDisk to disk "KitePaste"
    open theDisk
    set current view of container window of theDisk to icon view
    set toolbar visible of container window of theDisk to false
    set the bounds of container window of theDisk to {200, 120, 620, 380}
    set the position of item "KitePaste.app" of container window of theDisk to {140, 110}
    set the position of item "Applications" of container window of theDisk to {360, 110}
    update theDisk without registering applications
    delay 2
    close container window of theDisk
end tell
APPLESCRIPT

echo "==> 卸载并压缩为发布版..."
DEVICE=$(hdiutil info | grep "/Volumes/${VOLNAME}" | awk '{print $1}' | head -1)
hdiutil detach "$DEVICE" -quiet
/bin/rm -f "$OUT"
hdiutil convert "$RW" -format UDZO -o "$OUT" >/dev/null
/bin/rm -f "$RW"

echo "✅ DMG 完成: $OUT"
/bin/ls -lh "$OUT"
