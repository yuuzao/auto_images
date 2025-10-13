# Debian with systemd for Sysbox runtime
# Builds a minimal Debian systemd base suitable for running under Sysbox
# CI will auto-discover this image via .github/scripts/set-matrix.sh

FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Install systemd and useful base tools (no recommends to keep it lean)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       systemd systemd-sysv dbus sudo ca-certificates curl \
       iproute2 iputils-ping procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tweak systemd for container use:
# - Mask getty + udev services that are unnecessary in containers
# - Configure journald to be volatile and forward to console
RUN set -eux; \
    for s in \
      getty@.service \
      console-getty.service \
      systemd-udevd.service \
      systemd-udev-trigger.service \
      systemd-udev-settle.service \
    ; do \
      ln -sf /dev/null "/etc/systemd/system/${s}" || true; \
    done; \
    mkdir -p /etc/systemd/journald.conf.d; \
    printf "[Journal]\nStorage=volatile\nForwardToConsole=yes\nTTYPath=/dev/console\n" \
      > /etc/systemd/journald.conf.d/99-forward-to-console.conf

# Systemd expects cgroups to be mounted; Sysbox runtime handles this.
# VOLUME keeps the mountpoint distinct from container RW layer when needed.
VOLUME ["/sys/fs/cgroup"]

# Let Docker stop systemd cleanly
STOPSIGNAL SIGRTMIN+3

# Launch systemd by default
CMD ["/sbin/init"]

