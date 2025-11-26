#!/bin/bash

set -e

APP_NAME="RolledPromptMaker"
VERSION="1.2.0"
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

# Applications 폴더 심볼릭 링크 생성
ln -s /Applications "${DMG_TEMP_DIR}/Applications"

# DMG 생성
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP_DIR}" \
    -ov -format UDZO \
    "${FINAL_DMG}"

# 임시 디렉토리 삭제
rm -rf "${DMG_TEMP_DIR}"

echo "✅ DMG 생성 완료: ${FINAL_DMG}"
