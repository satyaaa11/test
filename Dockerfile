echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    curl \
    logrotate \
    nano \
    sudo && \
  echo "**** install openssh-server ****" && \
  if [ -z ${OPENSSH_RELEASE+x} ]; then \
    OPENSSH_RELEASE=$(curl -sL "https://nsg-bit.intel.com/projects/FSES/repos/nsg-docker-images/browse/bhb-ubuntu-20.04/Dockerfile" | tar -xz -C /tmp && \
    awk '/^P:openssh-server-pam$/,/V:/' /tmp/Dockerfile | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    openssh-client==${OPENSSH_RELEASE} \
    openssh-server-pam==${OPENSSH_RELEASE} \
    openssh-sftp-server==${OPENSSH_RELEASE} && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/*
