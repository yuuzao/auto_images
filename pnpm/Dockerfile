# 使用官方Node.js 22 Alpine镜像作为基础镜像
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装pnpm全局包管理器
RUN npm install -g pnpm@latest

# 设置pnpm配置，优化性能和缓存
RUN pnpm config set store-dir /pnpm-store && \
    pnpm config set cache-dir /pnpm-cache

# 创建pnpm存储目录
RUN mkdir -p /pnpm-store /pnpm-cache

# 设置环境变量
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 验证安装
RUN node --version && pnpm --version

# 设置默认命令
CMD ["pnpm", "--version"]
