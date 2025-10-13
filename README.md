# auto_images

一个用于“自动发现子目录中的 Dockerfile，并通过 GitHub Actions 持续构建与推送镜像到 Docker Hub”的极简模板/仓库。

- 自动扫描仓库中含 `Dockerfile` 的目录并构建
- 动态 Matrix 并行构建，多镜像同时推送
- 多架构支持：`linux/amd64`、`linux/arm64`（QEMU + Buildx）
- 定时更新（每周）与手动触发并存

## 目录结构

- `nginx/Dockerfile`：Nginx 最简示例镜像
- `python-app/Dockerfile`：Python HTTP Server 示例镜像
- `.github/workflows/auto-update.yml`：CI 工作流（构建与推送）
- `.github/scripts/set-matrix.sh`：扫描脚本（生成构建矩阵）

## 工作原理

1. 脚本 `./.github/scripts/set-matrix.sh` 会在仓库中搜索含有 `Dockerfile` 的目录（最大深度 2，忽略 `.git` 与 `.github`）。
2. 工作流 `auto-update.yml` 将上述目录作为 Matrix 项目逐个构建与推送：
   - 构建上下文：`./<目录名>`
   - Dockerfile 路径：`./<目录名>/Dockerfile`
   - 推送目标：`<DOCKERHUB_USERNAME>/<目录名>:latest`
3. 通过 Buildx + QEMU 构建多架构镜像，并使用 GHA 缓存加速。

> 注意：若使用二级目录（例如 `apps/web`），当前工作流会把 `apps/web` 原样作为镜像名拼接到标签中，Docker Hub 仓库名不支持斜杠。请将镜像目录放在仓库一级目录，或修改工作流中的 `tags` 规则做路径转换。

## 快速开始

### 1) 在 GitHub 仓库设置 Secrets（必需）

- `DOCKERHUB_USERNAME`：Docker Hub 用户名
- `DOCKERHUB_TOKEN`：Docker Hub Access Token（在 Docker Hub 账户设置中创建）

### 2) 添加或修改镜像目录

- 在仓库根目录下创建一个子目录，例如 `my-image/`，并在其中放置 `Dockerfile`。
- 目录名将作为镜像名的一部分：最终推送为 `DOCKERHUB_USERNAME/my-image:latest`。

### 3) 触发构建

- 手动触发：GitHub 的 Actions 页面选择“自动更新并推送 Docker 镜像 (智能扫描版)”工作流，点击“Run workflow”。
- 定时触发：工作流使用 cron `0 3 * * 0`（每周日 03:00 UTC）。

## 本地构建与验证

以两个示例为例：

- 构建并运行 Nginx：
  ```bash
  docker build -t <your-username>/nginx:latest ./nginx
  docker run --rm -p 8080:80 <your-username>/nginx:latest
  # 浏览器访问 http://localhost:8080
  ```

- 构建并运行 Python HTTP Server：
  ```bash
  docker build -t <your-username>/python-app:latest ./python-app
  docker run --rm -p 8000:8000 <your-username>/python-app:latest
  # 浏览器访问 http://localhost:8000
  ```

## 自定义与扩展

- 修改推送标签：默认仅推送 `latest`，如需加上日期、提交哈希或版本号，可在 `.github/workflows/auto-update.yml` 的 `tags:` 字段中自行扩展。例如：
  ```yaml
  tags: |
    ${{ secrets.DOCKERHUB_USERNAME }}/${{ matrix.image }}:latest
    ${{ secrets.DOCKERHUB_USERNAME }}/${{ matrix.image }}:${{ github.sha }}
  ```
- 修改架构：在 `platforms:` 中添加或移除目标架构。
- 调整扫描范围：在 `set-matrix.sh` 中调整 `find` 的 `-maxdepth` 或过滤规则。

## 常见问题

- 构建未发现我的目录？
  - 确保目录中存在名为 `Dockerfile` 的文件。
  - 默认最大深度为 2；更深层目录不会被扫描到。
  - 目录位于 `.git/`、`.github/` 下会被忽略。

- 推送时报“invalid reference format”或仓库名非法？
  - 目录名包含斜杠（如 `a/b`）会生成不合法的仓库名。请将镜像目录放在一级目录，或修改工作流以进行路径转换（例如将 `a-b` 作为仓库名）。

## 许可

本仓库未显式声明 License，如需公开发布请按需添加。

