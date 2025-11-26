#!/bin/bash

set -e

APP_NAME="RolledPromptMaker"
VERSION="1.2.1"
DMG_NAME="${APP_NAME}-${VERSION}"
SOURCE_APP="release/${APP_NAME}.app"
DMG_TEMP_DIR="dmg_temp"
FINAL_DMG="release/${DMG_NAME}.dmg"

# 기존 DMG 및 임시 디렉토리 삭제
rm -rf "${DMG_TEMP_DIR}"
rm -f "${FINAL_DMG}"
rm -f "release/${APP_NAME}.dmg"

# 임시 디렉토리 생성
mkdir -p "${DMG_TEMP_DIR}"

# 앱 복사
cp -R "${SOURCE_APP}" "${DMG_TEMP_DIR}/"

# 앱에서 격리 속성 제거 (Gatekeeper 경고 방지)
echo "🔓 격리 속성 제거 중..."
xattr -cr "${DMG_TEMP_DIR}/${APP_NAME}.app"

# Applications 폴더 심볼릭 링크 생성
ln -s /Applications "${DMG_TEMP_DIR}/Applications"

# DMG 생성
echo "📦 DMG 생성 중..."
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP_DIR}" \
    -ov -format UDZO \
    "${FINAL_DMG}"

# DMG에서도 격리 속성 제거
echo "🔓 DMG 격리 속성 제거 중..."
xattr -cr "${FINAL_DMG}"

# 임시 디렉토리 삭제
rm -rf "${DMG_TEMP_DIR}"

echo "✅ DMG 생성 완료: ${FINAL_DMG}"
echo "✅ 격리 속성이 제거되어 보안 경고 없이 설치 가능합니다"
