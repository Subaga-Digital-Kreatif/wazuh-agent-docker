FROM rockylinux/rockylinux:9
LABEL description="wazuh-agent as docker container"
LABEL version="4.12.0-4"

ENV AGENT_VERSION=4.12.0
ENV AGENT_RELEASE=1
ENV WAZUH_MANAGER=194.195.90.205
ENV WAZUH_AGENT_NAME=Core-apps

COPY entrypoint.sh /

RUN dnf update -y && dnf install -y \
  gawk \
  procps-ng \
  curl-minimal \
  net-tools \
  bash \
  gnupg2 \
  python3-podman

RUN groupadd -g 910 wazuh
RUN useradd -u 910 -g wazuh -G wazuh -r -d /var/ossec -m -s /sbin/nologin wazuh

COPY wazuh.repo /etc/yum.repos.d/
  
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
  dnf update -y && \
  WAZUH_MANAGER=${WAZUH_MANAGER} WAZUH_AGENT_NAME=${WAZUH_AGENT_NAME} dnf install -y wazuh-agent-${AGENT_VERSION}-${AGENT_RELEASE}

RUN sed -i "s/<address>.*<\/address>/<address>${WAZUH_MANAGER}<\/address>/g" /var/ossec/etc/ossec.conf && \
    sed -i "s/<agent_name>.*<\/agent_name>/<agent_name>${WAZUH_AGENT_NAME}<\/agent_name>/g" /var/ossec/etc/ossec.conf

ENTRYPOINT ["/entrypoint.sh"]
