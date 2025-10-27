# 使用官方Node.js 22 Alpine镜像作为基础镜像
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装pnpm全局包管理器
RUN npm install -g pnpm@latest

# 安装Vite和Vue相关工具
RUN pnpm add -g vite@latest @vitejs/create-vue vue@latest vue-router@latest

# 安装TypeScript和开发工具
RUN pnpm add -g typescript@latest tsx@latest

# 安装代码质量工具
RUN pnpm add -g eslint@latest @typescript-eslint/parser@latest @typescript-eslint/eslint-plugin@latest

# 安装CSS预处理器和构建工具
RUN pnpm add -g sass@latest

# 安装UnoCSS
RUN pnpm add -g @unocss/cli@latest

# 安装常用Vue生态工具
RUN pnpm add -g pinia@latest vue-i18n@latest

# 安装图表库
RUN pnpm add -g echarts@latest

# 安装Git相关工具
RUN apk add --no-cache git

# 设置pnpm配置，优化性能和缓存
RUN pnpm config set store-dir /pnpm-store && \
    pnpm config set cache-dir /pnpm-cache

# 创建pnpm存储目录
RUN mkdir -p /pnpm-store /pnpm-cache

# 设置环境变量
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 验证安装
RUN node --version && pnpm --version && vite --version && tsc --version && eslint --version

# 设置默认命令
CMD ["pnpm", "--version"]
