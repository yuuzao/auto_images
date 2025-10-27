# 使用官方Node.js 22 Alpine镜像作为基础镜像
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装pnpm全局包管理器
RUN npm install -g pnpm@latest

# 手动设置pnpm全局bin目录
RUN mkdir -p /usr/local/bin

# 设置pnpm配置，优化性能和缓存
RUN pnpm config set store-dir /pnpm-store && \
    pnpm config set cache-dir /pnpm-cache && \
    pnpm config set global-bin-dir /usr/local/bin

# 创建pnpm存储目录
RUN mkdir -p /pnpm-store /pnpm-cache

# 设置环境变量
ENV PNPM_HOME="/usr/local/bin"
ENV PATH="$PNPM_HOME:$PATH"

# 合并所有全局包安装，减少镜像层数
RUN pnpm add -g \
    vite@latest \
    create-vue@latest \
    vue@latest \
    vue-router@latest \
    typescript@latest \
    tsx@latest \
    eslint@latest \
    @typescript-eslint/parser@latest \
    @typescript-eslint/eslint-plugin@latest \
    sass@latest \
    @unocss/cli@latest \
    pinia@latest \
    vue-i18n@latest \
    echarts@latest

# 安装Git相关工具
RUN apk add --no-cache git

# 清理npm缓存和临时文件
RUN npm cache clean --force && \
    pnpm store prune && \
    rm -rf /tmp/* /var/cache/apk/*

# 验证安装
RUN node --version && pnpm --version && vite --version && tsc --version && eslint --version

# 设置默认命令
CMD ["pnpm", "--version"]
