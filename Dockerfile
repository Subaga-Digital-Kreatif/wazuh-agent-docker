# Dockerfile
FROM debian:12-slim

LABEL description="wazuh-agent as docker container"
LABEL version="4.12.0-3"

# environment
ENV DEBIAN_FRONTEND=noninteractive
ENV AGENT_VERSION=4.12.0-1

COPY entrypoint.sh ossec.conf /

# package installation
RUN apt-get update && apt-get install -y \
  mawk \
  procps \
  curl \
  net-tools \
  bash \
  apt-transport-https \
  gnupg2 \
  inotify-tools \
  python3-docker
  
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
  echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
  apt-get update && \
  apt-get install -y wazuh-agent=${AGENT_VERSION} && \
  mv /ossec.conf /var/ossec/etc/ && \
  rm -rf /var/lib/apt/lists/*

# entrypoint
ENTRYPOINT ["/entrypoint.sh"]
