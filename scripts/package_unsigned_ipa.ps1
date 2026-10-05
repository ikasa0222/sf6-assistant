<#
.SYNOPSIS
    SF6 Assistant (街霸6助手) - iOS Unsigned IPA Packaging PowerShell Automation Script
.DESCRIPTION
    Automates test execution, iOS unsigned release build, Payload assembly,
    and IPA compression on Windows / PowerShell environments.
#>

param (
    [string]$TagName = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
Set-Location $RootDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🥊 街霸6助手 (SF6 Assistant) - iOS 无签名 IPA PowerShell 打包脚本" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Environment Pre-check
Write-Host "[1/5] 检查构建环境与工具链..." -ForegroundColor Yellow
if (-not (Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Error "❌ 错误: 未检测到 flutter 命令，请确认 Flutter SDK 已加入环境变量 PATH。"
    exit 1
}

# Resolve version tag
if ([string]::IsNullOrWhiteSpace($TagName)) {
    if (Test-Path "pubspec.yaml") {
        $content = Get-Content "pubspec.yaml" -Raw
        if ($content -match "version:\s*([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)\+[0-9]+") {
            $TagName = "v" + $matches[1]
        }
    }
}
if ([string]::IsNullOrWhiteSpace($TagName)) {
    $TagName = "v1.2.6.5"
}
Write-Host "  目标打包版本: $TagName" -ForegroundColor Gray

# 2. Dependencies & Tests
Write-Host "[2/5] 获取依赖并执行单元测试..." -ForegroundColor Yellow
flutter pub get
flutter test

# 3. Build iOS Application
Write-Host "[3/5] 构建 iOS 原生工程 (Release / No-Codesign)..." -ForegroundColor Yellow
if ($IsMacOS) {
    flutter build ios --release --no-codesign
} else {
    Write-Host "  ⚠️ 当前非 macOS 宿主环境，尝试调用 flutter build ios --release --no-codesign..." -ForegroundColor Yellow
    try {
        flutter build ios --release --no-codesign
    } catch {
        Write-Warning "Windows 环境下无法编译原生 iOS 二进制。推荐将代码推送到 GitHub 由云端 macOS 自动化流水线（.github/workflows/build-ios.yml）打包。"
    }
}

# 4. Payload Assembly & Packaging
Write-Host "[4/5] 组装 Payload 结构并生成 IPA 安装包..." -ForegroundColor Yellow
$AppPath = "build/ios/iphoneos/Runner.app"
$StagingDir = "build/ipa_staging"
$OutputDir = "build/release_ios"
$PayloadDir = Join-Path $StagingDir "Payload"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$IpaUnsignedName = "SF6_Assistant_${TagName}_unsigned.ipa"
$IpaStandardName = "SF6_Assistant_${TagName}.ipa"
$IpaUnsignedPath = Join-Path $OutputDir $IpaUnsignedName
$IpaStandardPath = Join-Path $OutputDir $IpaStandardName
$IpaMirrorPath = "build/SF6_Assistant_unsigned.ipa"

if (Test-Path $AppPath) {
    if (Test-Path $StagingDir) {
        Remove-Item -Recurse -Force $StagingDir
    }
    New-Item -ItemType Directory -Path $PayloadDir -Force | Out-Null
    Copy-Item -Recurse -Force $AppPath $PayloadDir

    $ZipTempPath = Join-Path $StagingDir "archive.zip"
    Compress-Archive -Path $PayloadDir -DestinationPath $ZipTempPath -Force
    Move-Item -Force $ZipTempPath $IpaUnsignedPath
    Copy-Item -Force $IpaUnsignedPath $IpaStandardPath
    Copy-Item -Force $IpaUnsignedPath $IpaMirrorPath

    Remove-Item -Recurse -Force $StagingDir
} else {
    Write-Host "  Runner.app 尚不存在（通常需在 macOS 上生成），展示打包命令模板与架构说明..." -ForegroundColor Gray
}

# 5. Output Summary
Write-Host "[5/5] 打包脚本流程完毕！" -ForegroundColor Green
if (Test-Path $IpaUnsignedPath) {
    $fileItem = Get-Item $IpaUnsignedPath
    $hash = (Get-FileHash -Path $IpaUnsignedPath -Algorithm SHA256).Hash
    Write-Host "  📦 输出产物: $IpaUnsignedPath" -ForegroundColor Green
    Write-Host "     大小: $($fileItem.Length / 1MB) MB | SHA256: $hash" -ForegroundColor Gray
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "✅ 脚本执行完成，支持无签名侧载工具 (TrollStore / Sideloadly / 爱思助手)。" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
