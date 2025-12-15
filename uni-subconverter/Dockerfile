# 多阶段构建：前端构建阶段
FROM node:18-alpine AS frontend-builder

WORKDIR /build

# 下载 sub-web 前端源码
RUN wget https://github.com/CareyWang/sub-web/archive/refs/heads/master.zip -O sub-web.zip && \
    unzip sub-web.zip && \
    rm sub-web.zip && \
    mv sub-web-master sub-web

# 构建前端
WORKDIR /build/sub-web
RUN npm install && \
    npm run build

# 运行阶段：融合前后端
FROM ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的工具、运行时依赖和 Nginx
RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    ca-certificates \
    libcurl4 \
    libssl3 \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# 创建应用目录
WORKDIR /app

# 下载 subconverter 后端预编译二进制文件
# 尝试多种可能的下载链接
RUN (wget https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_linux64.tar.gz -O subconverter.tar.gz && \
     tar -xzf subconverter.tar.gz && \
     rm subconverter.tar.gz) || \
    (wget https://github.com/tindy2013/subconverter/releases/download/v0.9.0/subconverter_linux64.tar.gz -O subconverter.tar.gz && \
     tar -xzf subconverter.tar.gz && \
     rm subconverter.tar.gz) || \
    (wget https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_aarch64.tar.gz -O subconverter.tar.gz && \
     tar -xzf subconverter.tar.gz && \
     rm subconverter.tar.gz) && \
    chmod +x subconverter/subconverter

# 从构建阶段复制前端构建产物
COPY --from=frontend-builder /build/sub-web/dist /var/www/html

# 配置 Nginx
RUN rm -rf /etc/nginx/sites-enabled/default

# 复制 Nginx 配置文件
COPY nginx.conf /etc/nginx/sites-available/uni-converter
RUN ln -s /etc/nginx/sites-available/uni-converter /etc/nginx/sites-enabled/

# 复制 supervisor 配置文件
COPY supervisord.conf /etc/supervisor/conf.d/uni-converter.conf

# 暴露端口（Nginx 前端使用 80 端口，后端内部使用 25500 端口）
EXPOSE 80

# 使用 supervisor 启动所有服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

