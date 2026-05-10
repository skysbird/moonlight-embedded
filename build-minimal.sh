#!/bin/bash
set -e

echo "=== Building Moonlight for RG Cube XX (muOS) ==="
echo "Architecture: aarch64 (ARM64)"
echo "Target: RK3566 (Cortex-A55)"
echo ""

# 清理并创建构建目录
rm -rf build-rgcubexx
mkdir -p build-rgcubexx
cd build-rgcubexx

# 设置交叉编译器
export CROSS_COMPILE=aarch64-linux-gnu-
export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}g++
export AR=${CROSS_COMPILE}ar
export STRIP=${CROSS_COMPILE}strip

# 检查是否找到依赖库
if [ -d "/opt/rgcubexx" ]; then
    echo "Found pre-built libraries at /opt/rgcubexx"
    export RGCUBEXX_ROOT=/opt/rgcubexx
    export PKG_CONFIG_PATH=${RGCUBEXX_ROOT}/lib/pkgconfig

    # 使用手动编译的库
    SDL2_CMAKE_ARGS="-DSDL2_INCLUDE_DIR=${RGCUBEXX_ROOT}/include/SDL2 -DSDL2_LIBRARY=${RGCUBEXX_ROOT}/lib/libSDL2.a"
    OPUS_CMAKE_ARGS="-DOPUS_INCLUDE_DIR=${RGCUBEXX_ROOT}/include -DOPUS_LIBRARY=${RGCUBEXX_ROOT}/lib/libopus.a"
    ALSA_CMAKE_ARGS="-DALSA_INCLUDE_DIR=${RGCUBEXX_ROOT}/include -DALSA_LIBRARY=${RGCUBEXX_ROOT}/lib/libasound.a"
else
    echo "Pre-built libraries not found, will search system paths"
    SDL2_CMAKE_ARGS=""
    OPUS_CMAKE_ARGS=""
    ALSA_CMAKE_ARGS=""
fi

echo ""
echo "Running cmake..."

# 配置选项 - 针对 RG Cube XX / muOS 优化
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_C_FLAGS="-march=armv8.2-a -mtune=cortex-a55 -O3 -pipe -fomit-frame-pointer" \
    -DCMAKE_CXX_FLAGS="-march=armv8.2-a -mtune=cortex-a55 -O3 -pipe -fomit-frame-pointer" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
    -DThreads_FOUND=TRUE \
    -DENABLE_MMAL=OFF \
    -DENABLE_PULSEAUDIO=OFF \
    -DENABLE_X11=OFF \
    -DENABLE_OPENGL=OFF \
    -DENABLE_OPENGLES=OFF \
    -DENABLE_RK=ON \
    -DENABLE_SDL=ON \
    -DENABLE_FFMPEG=OFF \
    -DENABLE_LIBCEC=OFF \
    -DENABLE_RSVG=OFF \
    -DENABLE_VAAPI=OFF \
    -DENABLE_VDPAU=OFF \
    -DENABLE_GTK=OFF \
    -DENABLE_DBUS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,--as-needed" \
    ${SDL2_CMAKE_ARGS} \
    ${OPUS_CMAKE_ARGS} \
    ${ALSA_CMAKE_ARGS} \
    2>&1 | tee cmake.log

echo ""
echo "Building..."
make -j$(nproc) 2>&1 | tee build.log

echo ""
echo "=== Build Complete ==="
echo ""

# 查找并处理二进制文件
BINARY_PATH=""
for path in "src/moonlight" "moonlight" "./moonlight"; do
    if [ -f "$path" ]; then
        BINARY_PATH="$path"
        break
    fi
done

if [ -n "$BINARY_PATH" ]; then
    echo "Binary found: $BINARY_PATH"
    ls -lh $BINARY_PATH
    file $BINARY_PATH

    # 拷贝并重命名
    cp $BINARY_PATH moonlight-rgcubexx

    # 如果可执行，strip
    if file $BINARY_PATH | grep -q "executable"; then
        echo ""
        echo "Stripping binary..."
        ${STRIP} moonlight-rgcubexx || true
        ls -lh moonlight-rgcubexx
        file moonlight-rgcubexx

        # 检查依赖
        echo ""
        echo "Dynamic dependencies:"
        readelf -d moonlight-rgcubexx 2>/dev/null | grep NEEDED || echo "(readelf not available)"
    fi

    echo ""
    echo "=== Output ==="
    echo "Binary: build-rgcubexx/moonlight-rgcubexx"
    echo ""
    echo "Deploy to RG Cube XX:"
    echo "  scp moonlight-rgcubexx root@<device-ip>:/usr/bin/moonlight"
else
    echo "[ERROR] Binary not found"
    find . -name "moonlight" -type f 2>/dev/null || true
    exit 1
fi
