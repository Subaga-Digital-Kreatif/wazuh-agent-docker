# Dockerfile
FROM rockylinux/rockylinux:9

LABEL description="wazuh-agent as docker container"
LABEL version="4.12.0-3"

# environment
ENV AGENT_VERSION=4.12.0
ENV AGENT_RELEASE=1

COPY entrypoint.sh ossec.conf /

# package installation
RUN dnf update -y && dnf install -y \
  gawk \
  procps-ng \
  curl-minimal \
  net-tools \
  bash \
  gnupg2 \
  python3-podman

COPY wazuh.repo /etc/yum.repos.d/
  
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
  dnf update -y && \
  dnf install -y wazuh-agent-${AGENT_VERSION}-${AGENT_RELEASE} && \
  mv /ossec.conf /var/ossec/etc/

# entrypoint
ENTRYPOINT ["/entrypoint.sh"]
