# ==============================================================================
# SF6 Assistant (街霸6助手) - Local APK Build Automation Script
# Usage:
#   .\scripts\build_apk.ps1
#   .\scripts\build_apk.ps1 -SplitAbi
# ==============================================================================

param(
    [switch]$SplitAbi,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Set-Location $ProjectRoot
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  街霸6助手 (SF6 Assistant) 本地 APK 编译程序" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. 检查 Flutter 环境
Write-Host "`n[1/5] 检查编译工具链..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "未找到 flutter 命令，请确保 Flutter SDK 已添加至系统环境变量 PATH！"
    exit 1
}

$flutterVersion = & flutter --version
Write-Host "Flutter 工具链正常: $($flutterVersion.Split([Environment]::NewLine)[0])" -ForegroundColor Green

# 2. 读取项目版本号
$pubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$versionLine = Get-Content $pubspecPath | Where-Object { $_ -match "^version:\s*(.+)$" } | Select-Object -First 1
$rawVersion = if ($versionLine -match "^version:\s*(.+)$") { $Matches[1].Trim() } else { "1.2.7+2700" }
$displayVersion = $rawVersion -replace "\+", " (Build " -replace "$", ")"
Write-Host "目标应用版本: $rawVersion [$displayVersion]" -ForegroundColor Cyan

# 3. 运行自动化单元测试
if (-not $SkipTests) {
    Write-Host "`n[2/5] 执行轻量全量盲测与回归验证..." -ForegroundColor Yellow
    & flutter test --no-pub -j 1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "单元测试未能全部通过，编译流程中止！请修复测试后重试或使用 -SkipTests 跳过。"
        exit $LASTEXITCODE
    }
    Write-Host "所有单元测试通过 (100% 绿灯)！" -ForegroundColor Green
} else {
    Write-Host "`n[2/5] 跳过单元测试阶段 (-SkipTests)" -ForegroundColor Gray
}

# 4. 执行本地 APK 编译
$DistDir = Join-Path $ProjectRoot "dist\apk"
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

Write-Host "`n[3/5] 开始执行 Gradle Release APK 编译..." -ForegroundColor Yellow
if ($SplitAbi) {
    Write-Host "编译模式: 分架构瘦身包 (--split-per-abi)" -ForegroundColor Magenta
    & flutter build apk --release --split-per-abi --android-skip-build-dependency-validation
} else {
    Write-Host "编译模式: 全架构通用全量包 (Universal Fat APK)" -ForegroundColor Magenta
    & flutter build apk --release --android-skip-build-dependency-validation
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter Gradle 编译失败，请检查上方 Gradle 错误输出！"
    exit $LASTEXITCODE
}

# 5. 归档与输出信息
Write-Host "`n[4/5] 归档生成产物到 dist\apk 目录..." -ForegroundColor Yellow
$SourceApkDir = Join-Path $ProjectRoot "build\app\outputs\flutter-apk"

if ($SplitAbi) {
    $apks = Get-ChildItem -Path $SourceApkDir -Filter "app-*-release.apk"
    foreach ($apk in $apks) {
        $abiName = $apk.Name -replace "app-", "" -replace "-release.apk", ""
        $targetName = "SF6_Assistant_v$($rawVersion.Split('+')[0])_$abiName.apk"
        $destPath = Join-Path $DistDir $targetName
        Copy-Item -Path $apk.FullName -Destination $destPath -Force
        
        $sizeMb = [math]::Round($apk.Length / 1MB, 2)
        $hash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash
        Write-Host "✔ 产物 [$abiName]: $destPath ($sizeMb MB)" -ForegroundColor Green
        Write-Host "  SHA256: $hash" -ForegroundColor Gray
    }
} else {
    $universalApk = Join-Path $SourceApkDir "app-release.apk"
    if (Test-Path $universalApk) {
        $cleanVer = $rawVersion.Split('+')[0]
        $targetName = "SF6_Assistant_v$cleanVer.apk"
        $destPath = Join-Path $DistDir $targetName
        Copy-Item -Path $universalApk -Destination $destPath -Force
        
        $sizeMb = [math]::Round((Get-Item $destPath).Length / 1MB, 2)
        $hash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash
        Write-Host "✔ 产物 [通用包]: $destPath ($sizeMb MB)" -ForegroundColor Green
        Write-Host "  SHA256: $hash" -ForegroundColor Gray
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  编译大功告成！产物目录: $DistDir" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
