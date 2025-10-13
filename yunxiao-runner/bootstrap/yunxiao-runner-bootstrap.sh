#!/usr/bin/env bash
set -euo pipefail

log() { echo "[bootstrap] $(date -u +%Y-%m-%dT%H:%M:%SZ) $*"; }

already_installed() {
  # Heuristic: any runner-* systemd unit or install dir indicates presence
  if systemctl list-unit-files --type=service 2>/dev/null | grep -qE '^runner-.*\.service'; then
    return 0
  fi
  if compgen -G '/root/yunxiao/*/runner/bin/*' > /dev/null; then
    return 0
  fi
  return 1
}

download_installer() {
  # Determine installer URL: prefer explicit YUNXIAO_INSTALLER_URL, else derive from pkg endpoint, else fallback
  local dst="/tmp/aliyun/yunxiao-runner/install.sh"
  local base="${YUNXIAO_PKG_ENDPOINT:-}"
  local url="${YUNXIAO_INSTALLER_URL:-}"
  mkdir -p /tmp/aliyun/yunxiao-runner
  if [[ -z "$url" ]]; then
    if [[ -n "$base" ]]; then
      # strip trailing slash if any and append installer path
      url="${base%/}/install_linux.sh"
    else
      url="http://agent-install-cn-beijing.oss-cn-beijing.aliyuncs.com/install_linux.sh"
    fi
  fi
  log "Downloading installer from $url"
  if command -v wget >/dev/null 2>&1; then
    wget -t 3 -O "$dst" "$url"
  else
    curl -fsSL "$url" -o "$dst"
  fi
  chmod +x "$dst" || true
  echo "$dst"
}

ensure_docker() {
  log "Ensuring Docker Engine is enabled and running"
  # Enable services if unit files exist
  if [[ -f /lib/systemd/system/containerd.service ]]; then
    systemctl enable containerd.service || true
  fi
  if [[ -f /lib/systemd/system/docker.service ]]; then
    systemctl enable docker.service || true
  fi
  # Start services
  systemctl start containerd.service || true
  systemctl start docker.service || true
  # Wait for docker to become responsive (up to ~30s)
  for i in {1..30}; do
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
      log "Docker Engine is up"
      return 0
    fi
    sleep 1
  done
  log "Docker Engine did not become ready in time; continuing"
  return 0
}

run_install_from_env() {
  # Build command from environment variables if provided
  local required=(YUNXIAO_VERSION YUNXIAO_PKG_ENDPOINT YUNXIAO_TENANT YUNXIAO_REGISTER_TOKEN YUNXIAO_WONDER_ENDPOINT)
  local missing=0
  for k in "${required[@]}"; do
    if [[ -z "${!k:-}" ]]; then
      log "Missing required env: $k"
      missing=1
    fi
  done
  if [[ $missing -ne 0 ]]; then
    return 1
  fi
  local args=(
    -v "${YUNXIAO_VERSION}"
    -e "${YUNXIAO_PKG_ENDPOINT}"
    -t "${YUNXIAO_TENANT}"
    -a "${YUNXIAO_REGISTER_TOKEN}"
    -w "${YUNXIAO_WONDER_ENDPOINT}"
  )
  [[ -n "${YUNXIAO_INSTANCE_ID:-}" ]] && args+=( -i "${YUNXIAO_INSTANCE_ID}" )
  [[ -n "${YUNXIAO_INSTANCE_NAME:-}" ]] && args+=( -n "${YUNXIAO_INSTANCE_NAME}" )
  [[ -n "${YUNXIAO_RUNNER_GROUP_UUID:-}" ]] && args+=( -r "${YUNXIAO_RUNNER_GROUP_UUID}" )
  [[ -n "${YUNXIAO_AUTO_UPGRADE:-}" ]] && args+=( -u "${YUNXIAO_AUTO_UPGRADE}" )
  [[ -n "${YUNXIAO_SCAN_INTERVAL:-}" ]] && args+=( -s "${YUNXIAO_SCAN_INTERVAL}" )
  [[ -n "${YUNXIAO_CONCURRENCY:-}" ]] && args+=( -c "${YUNXIAO_CONCURRENCY}" )

  local installer
  installer=$(download_installer)
  log "Running install via downloaded script with env-configured args"
  /bin/sh "$installer" "${args[@]}"
}

run_install_cmd() {
  if [[ -n "${YUNXIAO_INSTALL_CMD:-}" ]]; then
    log "Running install command from YUNXIAO_INSTALL_CMD"
    # shellcheck disable=SC2086
    bash -lc "$YUNXIAO_INSTALL_CMD"
    return
  fi
  if [[ -f "/root/runner-install.sh" ]]; then
    log "Running install script at /root/runner-install.sh"
    chmod +x /root/runner-install.sh || true
    /bin/bash /root/runner-install.sh
    return
  fi
  if run_install_from_env; then
    return
  fi
  log "No install command provided. Set env YUNXIAO_INSTALL_CMD, mount /root/runner-install.sh, or provide env variables (YUNXIAO_VERSION/YUNXIAO_PKG_ENDPOINT/YUNXIAO_TENANT/YUNXIAO_REGISTER_TOKEN/YUNXIAO_WONDER_ENDPOINT)."
  return 1
}

enable_and_start() {
  # Enable and start discovered runner services
  mapfile -t services < <(systemctl list-unit-files --type=service | awk '/^runner-.*\.service/ {print $1}')
  if [[ ${#services[@]} -eq 0 ]]; then
    log "No runner services found to enable/start"
    return 0
  fi
  for s in "${services[@]}"; do
    log "Enabling $s"
    systemctl enable "$s" || true
    log "Starting $s"
    systemctl start "$s" || true
  done
}

main() {
  log "Starting Yunxiao Runner bootstrap"
  ensure_docker || true
  if already_installed; then
    log "Runner appears already installed; skipping installation"
    enable_and_start
    touch /var/lib/yunxiao-runner-bootstrap.done || true
    log "Bootstrap complete"
    exit 0
  fi
  run_install_cmd || { log "Install command not provided; marking bootstrap as done"; touch /var/lib/yunxiao-runner-bootstrap.done || true; exit 0; }
  enable_and_start
  touch /var/lib/yunxiao-runner-bootstrap.done || true
  log "Bootstrap complete"
}

main "$@"
