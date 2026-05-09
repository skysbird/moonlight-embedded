#!/bin/bash
# Docker 快速构建脚本 (适合 Linux/Mac)
# 用法: ./docker-build.sh [quick|static]

set -e

BUILD_TYPE=${1:-quick}

case $BUILD_TYPE in
    quick)
        DOCKERFILE="Dockerfile.rgcubexx-quick"
        BUILD_SCRIPT="./build-rgcubexx.sh"
        ;;
    static)
        DOCKERFILE="Dockerfile.rgcubexx"
        BUILD_SCRIPT="./build-static.sh"
        ;;
    *)
        echo "用法: $0 [quick|static]"
        echo "  quick  - 快速构建（动态链接，需要设备上有对应库）"
        echo "  static - 静态构建（完全静态链接，文件较大但兼容性好）"
        exit 1
        ;;
esac

echo "=== Building Moonlight for RG Cube XX ($BUILD_TYPE mode) ==="

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found. Please install Docker."
    exit 1
fi

# 构建镜像
echo "[1/3] Building Docker image from $DOCKERFILE..."
docker build -t moonlight-rgcubexx:$BUILD_TYPE -f $DOCKERFILE .

# 运行构建
echo ""
echo "[2/3] Running build..."
docker run --rm \
    -v "$(pwd):/workspace/moonlight-embedded" \
    -e BUILD_TYPE=$BUILD_TYPE \
    moonlight-rgcubexx:$BUILD_TYPE \
    bash -c "$BUILD_SCRIPT"

# 检查结果
echo ""
echo "[3/3] Checking output..."

OUTPUT_DIR="build-rgcubexx"
[ "$BUILD_TYPE" = "static" ] && OUTPUT_DIR="build-static"

if [ -f "$OUTPUT_DIR/moonlight-rgcubexx" ]; then
    echo "[SUCCESS] Binary created: $OUTPUT_DIR/moonlight-rgcubexx"
    ls -lh $OUTPUT_DIR/moonlight-rgcubexx
    echo ""
    echo "Deploy to RG Cube XX:"
    echo "  scp $OUTPUT_DIR/moonlight-rgcubexx root@<device-ip>:/usr/bin/moonlight"
    echo "  or copy via USB to /mnt/mmc/MUOS/application/moonlight/"
elif [ -f "$OUTPUT_DIR/src/moonlight" ]; then
    echo "[SUCCESS] Binary created: $OUTPUT_DIR/src/moonlight"
    ls -lh $OUTPUT_DIR/src/moonlight
else
    echo "[WARNING] Binary not found in expected location"
    ls -la $OUTPUT_DIR/ 2>/dev/null || true
fi

echo ""
echo "=== Done ==="
