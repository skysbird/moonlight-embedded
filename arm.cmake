SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR aarch64)

# 主 toolchain 路径
SET(TOOLCHAIN_ROOT /workspace/trimui-toolchain)

#include_directories(${TOOLCHAIN_ROOT}/aarch64-linux-gnu-7.5.0-linaro/aarch64-linux-gnu/libc/usr)

# 真正的 libc 在这
SET(CMAKE_SYSROOT ${TOOLCHAIN_ROOT}/usr)
#SET(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
SET(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_ROOT})

# 编译器
#SET(CMAKE_C_COMPILER ${TOOLCHAIN_ROOT}/bin/aarch64-linux-gnu-gcc)
#SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_ROOT}/bin/aarch64-linux-gnu-g++)

# 附加的非标准库，比如 SDL2, libpulse 等
#SET(CMAKE_PREFIX_PATH "/root/workspace/trimui-toolchain/usr")
include_directories(/workspace/trimui-toolchain/aarch64-linux-gnu-7.5.0-linaro/aarch64-linux-gnu/libc/usr/include)

include_directories(/workspace/trimui-toolchain/usr/include)
include_directories(/usr/include/)
include_directories(/usr/include/aarch64-linux-gnu/)
#/workspace/trimui-toolchain/usr/lib/libcurl.so \
#include_directories(/workspace/trimui-toolchain/usr/include)

link_directories(/opt/ffmpeg60/lib/)

# 告诉 cmake 不要从宿主系统乱找
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# pthread 强制开启
#set(THREADS_PTHREAD_ARG "2" CACHE STRING "Force pthreads")
#set(CMAKE_HAVE_THREADS_LIBRARY 1)
#set(CMAKE_USE_PTHREADS_INIT 1)
#set(Threads_FOUND TRUE)

