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
  log "No install command provided. Set env YUNXIAO_INSTALL_CMD or mount /root/runner-install.sh"
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
