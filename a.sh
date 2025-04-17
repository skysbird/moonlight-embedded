#!/bin/bash
rm -rf build

TOOLCHAIN_ROOT=/workspace/trimui-toolchain/usr
#export PKG_CONFIG_PATH=$TOOLCHAIN_ROOT/lib/pkgconfig
#export C_INCLUDE_PATH=$TOOLCHAIN_ROOT/include
#export LIBRARY_PATH=$TOOLCHAIN_ROOT/lib

export OPUS_INCLUDE_DIR=$TOOLCHAIN_ROOT/include

mkdir -p build && cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=arm.cmake \
  -DENABLE_MMAL=OFF \
  -DENABLE_PULSEAUDIO=OFF \
  -DENABLE_X11=OFF \
  -DENABLE_OPENGL=OFF 

make -j$(nproc)

#  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath=/usr/lib64" \

#  -DOPUS_INCLUDE_DIR=$TOOLCHAIN_ROOT/include \
#  -DOPUS_LIBRARY=$TOOLCHAIN_ROOT/lib/libopus.so \
#  -DALSA_INCLUDE_DIR=$TOOLCHAIN_ROOT/include \
#  -DALSA_LIBRARY=$TOOLCHAIN_ROOT/lib/libasound.so \
#  -DLibUUID_LIBRARY=/workspace/trimui-toolchain/usr/lib/libuuid.so 

