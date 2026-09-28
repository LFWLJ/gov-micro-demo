Write-Host "=== 政务管理系统 Docker 部署 ===" -ForegroundColor Cyan

$dockerVersion = docker --version 2>$null
if (-not $dockerVersion) {
    Write-Host "❌ 未检测到 Docker，请先安装 Docker Desktop" -ForegroundColor Red
    exit 1
}
Write-Host "✅ $dockerVersion" -ForegroundColor Green

$needBuild = -not (Test-Path "gov-gateway\target\gov-gateway-1.0.0.jar")
if ($needBuild) {
    Write-Host "=== 打包后端（第一次较慢）===" -ForegroundColor Yellow
    mvn clean package -DskipTests
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Maven 打包失败" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ 后端 jar 已就绪" -ForegroundColor Green

Write-Host "=== 启动 Docker Compose ===" -ForegroundColor Yellow
docker compose up -d --build

Write-Host "=== 等待服务启动（约 60 秒）===" -ForegroundColor Yellow
Start-Sleep -Seconds 60
docker compose ps

Write-Host ""
Write-Host "=== 访问地址 ===" -ForegroundColor Cyan
Write-Host "前端:        http://localhost"
Write-Host "Nacos 控制台: http://localhost:8080/nacos"
Write-Host "MinIO 控制台: http://localhost:9001"
Write-Host "账号: admin / 123456 / tenant_a" -ForegroundColor Yellow