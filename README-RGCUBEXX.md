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

> ⚠️ **不要直接复制单个二进制文件**。muOS 的 `/usr/lib/libmoonlight-common.so.4`
> 是 2.7.0 旧 ABI(180 KB),与本 build 编译时用的 2.7.1 ABI(233 KB)不兼容。
> 直接 push 二进制会出现"Decode failed - Invalid argument"刷屏 / 黑屏。
> **必须用 wrapper + 同包的 `.so.4` 一起部署**,见 [docs/DEPLOY-RGCUBEXX.md](docs/DEPLOY-RGCUBEXX.md)。

### 推荐:打 release 包后 adb 一键部署

```bash
# 1) 把 build 产物打包成 release zip(包含 wrapper、launch.sh、install.sh、README)
scripts/package-rgcubexx.sh \
  --binary     build-rgcubexx/moonlight-rgcubexx \
  --common     <path>/libmoonlight-common.so.4 \
  --gamestream <path>/libgamestream.so.4 \
  --version    2.7.1-muos.1

# 2) 推到设备并跑 install.sh
scripts/install-rgcubexx-adb.sh release/moonlight-rgcubexx-2.7.1-muos.1
```

`install.sh` 会落到 `/opt/muos/share/application/Moonlight/moonlight/`,旧文件
自动备份成 `moonlight.prev.<ts>`。设备 muOS Apps 菜单进 Moonlight 即可。

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
| `Dockerfile.rgcubexx` | Docker 构建配置(基于 debian:bookworm,内置交叉工具链 + 静态依赖) |
| `build-minimal.sh` | Docker 内默认入口,产出 `build-rgcubexx/moonlight-rgcubexx` |
| `build-rgcubexx.sh` / `build-static.sh` | 早期手工构建脚本(保留) |
| `cmake/muos-rk3566.cmake` | muOS RK3566 工具链配置 |
| `docker-build.bat` | Windows Docker 构建脚本 |
| `packaging/moonlight-wrapper.sh` | LD_LIBRARY_PATH wrapper(release 中作为 `moonlight`) |
| `packaging/launch.sh` | 修正后的独立启动器(去掉错误的 fbcon) |
| `packaging/install.sh` | 设备端安装器,被 `scripts/install-rgcubexx-adb.sh` 调用 |
| `packaging/README.txt` | release zip 内的最终用户说明 |
| `scripts/package-rgcubexx.sh` | 把 build 产物 + packaging 模板打成 release zip |
| `scripts/install-rgcubexx-adb.sh` | 本地通过 adb 部署 release 包到设备 |
| `docs/BUILD-RGCUBEXX.md` | 编译手册 |
| `docs/DEPLOY-RGCUBEXX.md` | 交付方案 + 黑屏根因记录 |

## 参考

- [Moonlight Embedded](https://github.com/moonlight-stream/moonlight-embedded)
- [muOS](https://muos.dev/)
- [RG Cube XX](https://anbernic.com/)
