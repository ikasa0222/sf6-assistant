# ==============================================================================
# SF6 Assistant (街霸6助手) - Local APK Build Automation Script (arm64-v8a only)
# Usage:
#   .\scripts\build_apk.ps1
#   .\scripts\build_apk.ps1 -SkipTests
# ==============================================================================

param(
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Set-Location $ProjectRoot
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  街霸6助手 (SF6 Assistant) 本地 APK 编译 (arm64-v8a)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. 检查 Flutter 环境
Write-Host "`n[1/4] 检查编译工具链..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "未找到 flutter 命令，请确保 Flutter SDK 已添加至系统环境变量 PATH！"
    exit 1
}

$flutterVersion = & flutter --version
Write-Host "Flutter 工具链正常: $($flutterVersion.Split([Environment]::NewLine)[0])" -ForegroundColor Green

# 2. 读取项目版本号
$pubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$loggerPath = Join-Path $ProjectRoot "lib\core\utils\app_logger.dart"

$displayVersion = "1.2.7.1"
$buildNumber = "2701"
if (Test-Path $loggerPath) {
    $loggerContent = Get-Content $loggerPath -Raw
    if ($loggerContent -match "currentAppVersion\s*=\s*'v?([^']+)'") {
        $displayVersion = $Matches[1]
    }
    if ($loggerContent -match "currentBuildNumber\s*=\s*'([^']+)'") {
        $buildNumber = $Matches[1]
    }
}

Write-Host "目标应用版本: v$displayVersion (Build $buildNumber)" -ForegroundColor Cyan
Write-Host "目标芯片架构: arm64-v8a (主流 64 位安卓)" -ForegroundColor Magenta

# 3. 运行自动化单元测试
if (-not $SkipTests) {
    Write-Host "`n[2/4] 执行轻量全量盲测与回归验证..." -ForegroundColor Yellow
    & flutter test --no-pub -j 1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "单元测试未能全部通过，编译流程中止！请修复测试后重试或使用 -SkipTests 跳过。"
        exit $LASTEXITCODE
    }
    Write-Host "所有单元测试通过 (100% 绿灯)！" -ForegroundColor Green
} else {
    Write-Host "`n[2/4] 跳过单元测试阶段 (-SkipTests)" -ForegroundColor Gray
}

# 4. 执行本地 APK 编译 (arm64-v8a only)
$DistDir = Join-Path $ProjectRoot "dist\apk"
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

Write-Host "`n[3/4] 开始执行 Gradle Release APK 编译 (仅编译 arm64-v8a 极速构建)..." -ForegroundColor Yellow
& flutter build apk --release --target-platform android-arm64 --build-name=$displayVersion --build-number=$buildNumber --android-skip-build-dependency-validation

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter Gradle 编译失败，请检查上方 Gradle 错误输出！"
    exit $LASTEXITCODE
}

# 5. 归档与输出信息
Write-Host "`n[4/4] 归档生成产物到 dist\apk 目录..." -ForegroundColor Yellow
$SourceApk = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $SourceApk) {
    $targetName = "SF6_Assistant_v$displayVersion`_arm64-v8a.apk"
    $destPath = Join-Path $DistDir $targetName
    Copy-Item -Path $SourceApk -Destination $destPath -Force

    $sizeMb = [math]::Round((Get-Item $destPath).Length / 1MB, 2)
    $hash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash
    Write-Host "✔ 生成专属架构包 [arm64-v8a]: $destPath ($sizeMb MB)" -ForegroundColor Green
    Write-Host "  SHA256: $hash" -ForegroundColor Gray
} else {
    Write-Error "未找到编译生成物: $SourceApk"
    exit 1
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  编译完成！专属 arm64-v8a 安装包位于: $DistDir" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
