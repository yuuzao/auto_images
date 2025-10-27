# Node.js 22 + pnpm + Vue3 + TypeScript 完整开发镜像

这是一个基于Node.js 22 Alpine的完整Docker镜像，预装了现代Vue3开发所需的所有工具，特别适合中后台管理系统开发。

## 特性

- 🚀 基于Node.js 22 LTS版本
- 📦 预装最新版pnpm包管理器
- ⚡ 预装Vite 7构建工具和Vue 3框架
- 🛠️ 包含Vue Router、Pinia状态管理、Vue I18n国际化
- 📝 完整的TypeScript开发环境
- 🎨 支持Sass预处理器和UnoCSS原子化CSS
- 🔍 ESLint代码检查和格式化工具
- 📊 ECharts图表库支持
- 🎯 Naive UI组件库支持
- 🔧 Git工具和版本控制支持
- 🪶 使用Alpine Linux，镜像体积最小
- ⚡ 优化的pnpm配置，提升性能

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

# 创建新的Vue项目
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && npm create vue@latest my-vue-app"

# 启动Vite开发服务器
docker run -it --rm -p 5173:5173 -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm dev --host"
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
- **构建工具**: Vite 7 (最新版)
- **前端框架**: Vue 3 (最新版)
- **类型系统**: TypeScript (最新版)
- **状态管理**: Pinia (最新版)
- **路由**: Vue Router (最新版)
- **国际化**: Vue I18n (最新版)
- **UI组件库**: Naive UI支持
- **CSS框架**: UnoCSS + Sass支持
- **代码检查**: ESLint + TypeScript ESLint
- **图表库**: ECharts支持
- **脚手架**: @vitejs/create-vue
- **工作目录**: /app
- **pnpm存储目录**: /pnpm-store
- **pnpm缓存目录**: /pnpm-cache

## 环境变量

- `PNPM_HOME`: pnpm安装路径
- `PATH`: 包含pnpm路径

## Vue3 + TypeScript项目快速开始

### 创建新项目

```bash
# 使用Docker创建Vue3 + TypeScript项目
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && npm create vue@latest my-vue-app"

# 进入项目目录并安装依赖
cd my-vue-app
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm install"
```

### 开发模式

```bash
# 启动开发服务器
docker run -it --rm -p 5173:5173 -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm dev --host"

# TypeScript类型检查
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm typecheck"

# 代码检查和格式化
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm lint"
```

### 构建生产版本

```bash
# 构建项目
docker run -it --rm -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm build"

# 预览生产构建
docker run -it --rm -p 4173:4173 -v $(pwd):/app node22-pnpm sh -c "cd /app && pnpm preview --host"
```
## 注意事项

- 镜像已预配置pnpm的存储和缓存目录
- 预装了完整的Vue3 + TypeScript开发环境
- 包含ESLint、Sass、UnoCSS等现代开发工具
- 支持ECharts图表和Naive UI组件库
- 建议在CI/CD中使用 `--frozen-lockfile` 参数确保依赖版本一致
- 生产环境建议使用多阶段构建进一步优化镜像大小
- 开发时记得映射端口5173(Vite默认端口)或4173(预览端口)
