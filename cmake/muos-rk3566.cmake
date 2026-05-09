SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR aarch64)

# RG Cube XX / muOS 配置
# muOS 使用 Rockchip RK3566 (ARM Cortex-A55)

# 检测是否在 Docker 中
IF(DEFINED ENV{CROSS_COMPILE})
    SET(CMAKE_C_COMPILER $ENV{CC})
    SET(CMAKE_CXX_COMPILER $ENV{CXX})
    SET(CMAKE_AR $ENV{AR})
ELSE()
    # 本地交叉编译
    SET(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
    SET(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
    SET(CMAKE_AR aarch64-linux-gnu-ar)
ENDIF()

# 查找根路径模式
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# muOS 特定标志 (RK3566 - Cortex-A55)
# -march=armv8.2-a 支持 ARMv8.2-A 指令集
# -mtune=cortex-a55 针对 Cortex-A55 优化
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8.2-a -mtune=cortex-a55 -O3 -pipe -fomit-frame-pointer" CACHE STRING "" FORCE)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8.2-a -mtune=cortex-a55 -O3 -pipe -fomit-frame-pointer" CACHE STRING "" FORCE)

# RG Cube XX 特定定义
ADD_DEFINITIONS(-DRG_CUBE_XX)
ADD_DEFINITIONS(-DRK3566)
