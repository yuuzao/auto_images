# Node.js 22 + pnpm 最小镜像

这是一个基于Node.js 22 Alpine的最小Docker镜像，预装了pnpm包管理器。

## 特性

- 🚀 基于Node.js 22 LTS版本
- 📦 预装最新版pnpm包管理器
- 🪶 使用Alpine Linux，镜像体积最小
- ⚡ 优化的pnpm配置，提升性能
- 🔧 预配置的缓存目录

## 使用方法

### 构建镜像

```bash
docker build -t node22-pnpm .
```

### 运行容器

```bash
# 查看版本信息
docker run --rm node22-pnpm

# 进入交互式shell
docker run -it --rm node22-pnpm sh

# 挂载项目目录并安装依赖
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm install"
```

### 作为基础镜像使用

```dockerfile
FROM node22-pnpm:latest

# 复制项目文件
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 构建项目
RUN pnpm build

# 启动应用
CMD ["pnpm", "start"]
```

## 镜像信息

- **基础镜像**: node:22-alpine
- **包管理器**: pnpm (最新版)
- **工作目录**: /app
- **pnpm存储目录**: /pnpm-store
- **pnpm缓存目录**: /pnpm-cache

## 环境变量

- `PNPM_HOME`: pnpm安装路径
- `PATH`: 包含pnpm路径

## 注意事项

- 镜像已预配置pnpm的存储和缓存目录
- 建议在CI/CD中使用 `--frozen-lockfile` 参数确保依赖版本一致
- 生产环境建议使用多阶段构建进一步优化镜像大小
