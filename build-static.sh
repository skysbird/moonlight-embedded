#!/bin/bash
set -e

echo "=== Building Moonlight for RG Cube XX (muOS) - Static Build ==="
echo "This build creates a static binary that can run on RG Cube XX"
echo ""

# 清理并创建构建目录
rm -rf build-static
mkdir -p build-static
cd build-static

# 检查是否在 Docker 中
if [ -z "$RGCUBEXX_ROOT" ]; then
    echo "[WARNING] Not running in Docker, using system paths"
    RGCUBEXX_ROOT=/opt/rgcubexx
fi

# 设置路径
export PKG_CONFIG_PATH=${RGCUBEXX_ROOT}/lib/pkgconfig

# 配置 cmake
echo "Running cmake..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=${CC:-aarch64-linux-gnu-gcc} \
    -DCMAKE_CXX_COMPILER=${CXX:-aarch64-linux-gnu-g++} \
    -DCMAKE_TOOLCHAIN_FILE=../cmake/muos-rk3566.cmake \
    -DCMAKE_PREFIX_PATH=${RGCUBEXX_ROOT} \
    -DCMAKE_FIND_ROOT_PATH=${RGCUBEXX_ROOT} \
    -DThreads_FOUND=TRUE \
    -DENABLE_MMAL=OFF \
    -DENABLE_PULSEAUDIO=OFF \
    -DENABLE_X11=OFF \
    -DENABLE_OPENGL=OFF \
    -DENABLE_OPENGLES=OFF \
    -DENABLE_RK=OFF \
    -DENABLE_SDL=ON \
    -DENABLE_FFMPEG=ON \
    -DENABLE_LIBCEC=OFF \
    -DENABLE_RSVG=OFF \
    -DENABLE_VAAPI=OFF \
    -DENABLE_VDPAU=OFF \
    -DENABLE_GTK=OFF \
    -DENABLE_DBUS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -L${RGCUBEXX_ROOT}/lib" \
    -DSDL2_INCLUDE_DIR=${RGCUBEXX_ROOT}/include/SDL2 \
    -DSDL2_LIBRARY=${RGCUBEXX_ROOT}/lib/libSDL2.a \
    -DOPUS_INCLUDE_DIR=${RGCUBEXX_ROOT}/include \
    -DOPUS_LIBRARY=${RGCUBEXX_ROOT}/lib/libopus.a \
    -DCURL_INCLUDE_DIR=${RGCUBEXX_ROOT}/include \
    -DCURL_LIBRARY=${RGCUBEXX_ROOT}/lib/libcurl.a \
    -DAVCODEC_INCLUDE_DIR=${RGCUBEXX_ROOT}/include \
    -DAVCODEC_LIBRARY=${RGCUBEXX_ROOT}/lib/libavcodec.a \
    -DAVUTIL_LIBRARY=${RGCUBEXX_ROOT}/lib/libavutil.a \
    -DSWRESAMPLE_LIBRARY=${RGCUBEXX_ROOT}/lib/libswresample.a \
    -DALSA_INCLUDE_DIR=${RGCUBEXX_ROOT}/include \
    -DALSA_LIBRARY=${RGCUBEXX_ROOT}/lib/libasound.a \
    2>&1 | tee cmake.log

# 编译
echo ""
echo "Building..."
make VERBOSE=1 -j$(nproc) 2>&1 | tee build.log

# 显示输出文件信息
echo ""
echo "=== Build Complete ==="
echo ""

# 查找生成的二进制文件
if [ -f "src/moonlight" ]; then
    echo "Binary location: src/moonlight"
    ls -lh src/moonlight
    file src/moonlight

    # Strip 二进制文件
    echo ""
    echo "Stripping binary..."
    ${STRIP:-aarch64-linux-gnu-strip} src/moonlight -o moonlight-rgcubexx
    ls -lh moonlight-rgcubexx
    file moonlight-rgcubexx

    # 检查依赖
    echo ""
    echo "Dependencies (should be minimal for static build):"
    aarch64-linux-gnu-readelf -d moonlight-rgcubexx | grep NEEDED || echo "No dynamic dependencies (statically linked)"

    echo ""
    echo "=== Done ==="
    echo "Binary: build-static/moonlight-rgcubexx"
    echo ""
    echo "To deploy to RG Cube XX:"
    echo "  1. Copy moonlight-rgcubexx to your device"
    echo "  2. Rename to 'moonlight' and place in /usr/bin or app directory"
else
    echo "[ERROR] Binary not found"
    exit 1
fi
