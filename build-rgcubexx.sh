#!/bin/bash
set -e

echo "=== Building Moonlight for RG Cube XX (muOS) ==="

# 清理并创建构建目录
rm -rf build-rgcubexx
mkdir -p build-rgcubexx
cd build-rgcubexx

# 设置交叉编译工具链
export CROSS_COMPILE=aarch64-linux-gnu-
export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}g++
export AR=${CROSS_COMPILE}ar
export STRIP=${CROSS_COMPILE}strip

# muOS 系统库路径（RG Cube XX）
# 根据 muOS 实际路径调整
export MUOS_ROOT=/opt/muos
export MUOS_INCLUDE=${MUOS_ROOT}/usr/include
export MUOS_LIB=${MUOS_ROOT}/usr/lib

# 配置选项
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
    -DThreads_FOUND=TRUE \
    -DENABLE_MMAL=OFF \
    -DENABLE_PULSEAUDIO=OFF \
    -DENABLE_X11=OFF \
    -DENABLE_OPENGL=OFF \
    -DENABLE_OPENGLES=ON \
    -DENABLE_RKMPP=ON \
    -DENABLE_LIBCEC=OFF \
    -DENABLE_RSVG=OFF \
    -DENABLE_VAAPI=OFF \
    -DENABLE_VDPAU=OFF \
    -DENABLE_GTK=OFF \
    -DENABLE_DBUS=OFF \
    -DENABLE_FFMPEG=ON \
    -DENABLE_SDL=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-as-needed" \
    2>&1 | tee cmake.log

# 编译
make -j$(nproc) 2>&1 | tee build.log

# 显示输出文件信息
echo ""
echo "=== Build Complete ==="
ls -la src/moonlight || echo "Binary location may vary"
file src/moonlight 2>/dev/null || true

echo ""
echo "=== Stripping binary for RG Cube XX ==="
${STRIP} src/moonlight -o moonlight-rgcubexx 2>/dev/null || true
ls -la moonlight-rgcubexx 2>/dev/null || true
