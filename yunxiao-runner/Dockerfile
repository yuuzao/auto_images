# Yunxiao (Alibaba Cloud DevOps) Pipeline Runner image
# Designed to run under Sysbox runtime with systemd as PID 1
# It installs systemd and a first-boot bootstrap that executes the
# org-specific Runner install command provided via env or mounted file.

FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       systemd systemd-sysv dbus sudo ca-certificates curl wget gnupg \
       iproute2 iputils-ping procps iptables pigz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Reduce unneeded services in containerized systemd and make journald volatile
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
    printf "[Journal]\nStorage=volatile\nForwardToConsole=yes\nTTYPath=/dev/console\n" > /etc/systemd/journald.conf.d/99-forward-to-console.conf

# The Yunxiao installer will be downloaded at runtime by the bootstrap script

# Install Docker Engine (dockerd), CLI, Buildx, and Compose from Docker's repo
RUN set -eux; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
    chmod a+r /etc/apt/keyrings/docker.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
      > /etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    # Enable docker + containerd at boot by creating wants symlinks (avoid using systemctl during build)
    ln -sf /lib/systemd/system/containerd.service /etc/systemd/system/multi-user.target.wants/containerd.service; \
    ln -sf /lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service

# Bootstrap script will run at first boot and install the Runner using a
# per-organization install command. Provide it via env YUNXIAO_INSTALL_CMD
# or mount a file at /root/runner-install.sh.
COPY bootstrap/yunxiao-runner-bootstrap.sh /usr/local/bin/yunxiao-runner-bootstrap.sh
RUN chmod +x /usr/local/bin/yunxiao-runner-bootstrap.sh

# Systemd oneshot unit to run the bootstrap on first boot
COPY bootstrap/yunxiao-runner-bootstrap.service /etc/systemd/system/yunxiao-runner-bootstrap.service
RUN ln -sf /etc/systemd/system/yunxiao-runner-bootstrap.service \
         /etc/systemd/system/multi-user.target.wants/yunxiao-runner-bootstrap.service

# Systemd expects cgroups; Sysbox runtime will mount them at runtime
VOLUME ["/sys/fs/cgroup"]

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
