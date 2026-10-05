#!/usr/bin/env bash
# ==============================================================================
# SF6 Assistant (街霸6助手) - Unsigned IPA Packaging Automation Script
# Targets: macOS / Linux (CI) / Git Bash
# Produces: SF6_Assistant_{TAG}_unsigned.ipa & SF6_Assistant_{TAG}.ipa
# ==============================================================================
set -euo pipefail

# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

echo "=========================================================="
echo "🥊 街霸6助手 (SF6 Assistant) - iOS 无签名 IPA 本地打包脚本"
echo "=========================================================="

# 1. Environment Pre-check
echo "[1/5] 检查构建环境..."
if ! command -v flutter &>/dev/null; then
    echo "❌ 错误: 未检测到 flutter 命令，请先安装 Flutter SDK 并将其添加到 PATH。"
    exit 1
fi

echo "  Flutter 版本: $(flutter --version | head -n 1)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v xcodebuild &>/dev/null; then
        echo "❌ 错误: 未检测到 xcodebuild 命令，请确保已安装 Xcode 并配置命令行工具。"
        exit 1
    fi
    echo "  Xcode 版本: $(xcodebuild -version | head -n 1)"
else
    echo "⚠️ 提示: 当前非 macOS 环境 ($OSTYPE)。如需编译原生 iOS 二进制，请使用 macOS 或云端 GitHub Actions CI/CD。"
fi

# Resolve version tag from pubspec.yaml or environment variable
if [ -z "${TAG_NAME:-}" ]; then
    VERSION_LINE=$(grep "^version:" pubspec.yaml | head -n 1)
    VERSION_NUM=$(echo "$VERSION_LINE" | sed -E 's/version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)\+[0-9]+/\1/')
    TAG_NAME="v${VERSION_NUM}"
fi
echo "  目标版本: ${TAG_NAME}"

# 2. Dependencies and Unit Tests
echo "[2/5] 获取依赖并运行测试套件..."
flutter pub get

echo "  执行 flutter test 校验工程代码稳定性..."
flutter test

# 3. Build iOS Application without Code Signing
echo "[3/5] 构建 iOS 原生工程 (Release / No-Codesign)..."
flutter build ios --release --no-codesign

APP_PATH="build/ios/iphoneos/Runner.app"
if [ ! -d "${APP_PATH}" ]; then
    echo "❌ 错误: 构建产物 ${APP_PATH} 不存在，编译可能已中断。"
    exit 1
fi

# 4. Payload Assembly and Packaging
echo "[4/5] 组装 Payload 目录并压缩封装 IPA..."
STAGING_DIR="build/ipa_staging"
OUTPUT_DIR="build/release_ios"

# Trap cleanup
cleanup() {
    rm -rf "${STAGING_DIR}"
}
trap cleanup EXIT

rm -rf "${STAGING_DIR}" "${OUTPUT_DIR}"
mkdir -p "${STAGING_DIR}/Payload"
mkdir -p "${OUTPUT_DIR}"

# Copy Runner.app into Payload/
cp -R "${APP_PATH}" "${STAGING_DIR}/Payload/"

# Create IPA files
IPA_UNSIGNED_NAME="SF6_Assistant_${TAG_NAME}_unsigned.ipa"
IPA_STANDARD_NAME="SF6_Assistant_${TAG_NAME}.ipa"

cd "${STAGING_DIR}"
if ! command -v zip &>/dev/null; then
    echo "❌ 错误: 未检测到 zip 命令，无法打包 IPA。"
    exit 1
fi

zip -r -q "${IPA_UNSIGNED_NAME}" Payload
cp "${IPA_UNSIGNED_NAME}" "${IPA_STANDARD_NAME}"

mv "${IPA_UNSIGNED_NAME}" "${ROOT_DIR}/${OUTPUT_DIR}/"
mv "${IPA_STANDARD_NAME}" "${ROOT_DIR}/${OUTPUT_DIR}/"
cd "${ROOT_DIR}"

# Also mirror primary IPA to build/
cp "${OUTPUT_DIR}/${IPA_UNSIGNED_NAME}" "build/SF6_Assistant_unsigned.ipa"

# 5. Verification and Summary
echo "[5/5] 打包完成！校验产物..."
for ipa in "${OUTPUT_DIR}/${IPA_UNSIGNED_NAME}" "${OUTPUT_DIR}/${IPA_STANDARD_NAME}" "build/SF6_Assistant_unsigned.ipa"; do
    if [ -f "$ipa" ]; then
        SIZE=$(du -h "$ipa" | cut -f1)
        if command -v shasum &>/dev/null; then
            HASH=$(shasum -a 256 "$ipa" | cut -d' ' -f1)
        elif command -v sha256sum &>/dev/null; then
            HASH=$(sha256sum "$ipa" | cut -d' ' -f1)
        else
            HASH="N/A"
        fi
        echo "  📦 产物: $ipa"
        echo "     大小: ${SIZE} | SHA256: ${HASH}"
    fi
done

echo "=========================================================="
echo "✅ iOS 未签名 IPA 打包大功告成！"
echo "   主要产物: ${OUTPUT_DIR}/${IPA_UNSIGNED_NAME}"
echo "   兼容产物: ${OUTPUT_DIR}/${IPA_STANDARD_NAME}"
echo "   可直接使用 TrollStore (巨魔商店) 或 Sideloadly 免越狱安装。"
echo "=========================================================="
