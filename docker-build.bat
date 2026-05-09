@echo off
chcp 65001 >nul
echo === Building Moonlight for RG Cube XX using Docker ===
echo.

REM 检查 Docker 是否可用
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker not found. Please install Docker Desktop.
    exit /b 1
)

REM 构建 Docker 镜像
echo [1/3] Building Docker image...
docker build -t moonlight-rgcubexx-builder -f Dockerfile.rgcubexx .
if %errorlevel% neq 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

REM 运行构建
echo.
echo [2/3] Running build in Docker...
docker run --rm -v "%cd%:/workspace/moonlight-embedded" moonlight-rgcubexx-builder
if %errorlevel% neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)

REM 检查结果
echo.
echo [3/3] Checking output...
if exist "build-rgcubexx\moonlight-rgcubexx" (
    echo [SUCCESS] Binary created: build-rgcubexx\moonlight-rgcubexx
    echo.
    echo File info:
    docker run --rm -v "%cd%:/workspace/moonlight-embedded" --entrypoint /bin/bash moonlight-rgcubexx-builder -c "file /workspace/moonlight-embedded/build-rgcubexx/moonlight-rgcubexx"
) else if exist "build-rgcubexx\src\moonlight" (
    echo [SUCCESS] Binary created: build-rgcubexx\src\moonlight
    echo.
    echo You can now copy this to your RG Cube XX
) else (
    echo [WARNING] Binary not found in expected location
    echo Checking build-rgcubexx directory...
    dir /b build-rgcubexx 2>nul || echo Directory is empty
)

echo.
echo === Done ===
