
FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Install useful base tools (no recommends to keep it lean)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo ca-certificates curl \
       wget \
       httpie \
       jq \
       yq \
       git \
       ssh \
       unzip \
       iproute2 \
       net-tools \
       dnsutils \
       iputils-ping \
       traceroute \
       # 文本编辑和处理工具
       vim nano \
       # 系统监控工具
       htop tree \
       # 压缩工具
       zip tar gzip \
       # 进程和系统工具
       procps psmisc \
       # 开发工具
       build-essential \
       # 其他实用工具
       less man-db \
       # 网络工具增强
       nmap telnet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
