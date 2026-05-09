# Moonlight for RG Cube XX (muOS)

为 Anbernic RG Cube XX (RK3566) 优化的 Moonlight 客户端构建配置。

## 硬件规格

- **SoC**: Rockchip RK3566 (ARM Cortex-A55, 四核)
- **GPU**: Mali-G52
- **架构**: aarch64 / ARM64
- **OS**: muOS (Linux-based)

## 快速开始

### 方法 1: 使用 Docker (推荐)

#### Windows
```powershell
# 运行构建
docker-build.bat
```

#### Linux/Mac
```bash
# 构建 Docker 镜像
docker build -t moonlight-rgcubexx-builder -f Dockerfile.rgcubexx .

# 运行构建
docker run --rm -v $(pwd):/workspace/moonlight-embedded moonlight-rgcubexx-builder
```

### 方法 2: 本地交叉编译

需要安装 aarch64-linux-gnu 工具链:
```bash
# Ubuntu/Debian
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu cmake

# 运行构建
./build-rgcubexx.sh
```

## 部署到 RG Cube XX

### 1. 通过 USB 传输
```bash
# 设备连接到电脑后，推送到设备
adb push build-static/moonlight-rgcubexx /mnt/mmc/MUOS/application/moonlight/
# 或者通过 MTP 直接复制
```

### 2. 通过 SSH/SCP
```bash
scp build-static/moonlight-rgcubexx root@192.168.x.x:/usr/bin/moonlight
```

### 3. 运行
在 RG Cube XX 上:
```bash
# 直接运行
/mnt/mmc/MUOS/application/moonlight/moonlight-rgcubexx

# 或者复制到系统目录
chmod +x /mnt/mmc/MUOS/application/moonlight/moonlight-rgcubexx
```

## 配置 muOS 启动脚本

创建启动脚本 `moonlight.sh`:
```bash
#!/bin/bash
export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
exec /mnt/mmc/MUOS/application/moonlight/moonlight-rgcubexx "$@"
```

## 已知优化

本分支包含以下针对 RG Cube XX 的优化:

1. **timeout**: 修复 HTTP 响应解析 bug
2. **reuse**: 禁用连接重用，提高嵌入式设备稳定性
3. **remove old ssl method**: 适配新版 OpenSSL
4. **curl lib**: 精简依赖，适合静态链接
5. **multi_client_trimui**: 支持在游戏运行时配对

## 视频解码

RK3566 支持硬件解码:
- H.264
- H.265/HEVC

Moonlight 会自动检测并使用可用的硬件解码器。

## 故障排除

### 缺少库
如果运行时报错缺少库，检查:
```bash
# 查看依赖
readelf -d moonlight-rgcubexx | grep NEEDED

# 在设备上查找库
find /usr -name "libssl*" 2>/dev/null
```

### 音频问题
muOS 使用 ALSA，确保配置正确:
```bash
# 检查音频设备
aplay -l
```

### 控制器映射
控制器映射文件位于:
```
/usr/share/SDL2/gamecontrollerdb.txt
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `Dockerfile.rgcubexx` | Docker 构建配置 |
| `build-rgcubexx.sh` | 标准构建脚本 |
| `build-static.sh` | 静态链接构建脚本 |
| `cmake/muos-rk3566.cmake` | muOS RK3566 工具链配置 |
| `docker-build.bat` | Windows Docker 构建脚本 |

## 参考

- [Moonlight Embedded](https://github.com/moonlight-stream/moonlight-embedded)
- [muOS](https://muos.dev/)
- [RG Cube XX](https://anbernic.com/)
