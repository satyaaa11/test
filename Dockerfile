FROM af01p-fm.devtools.intel.com:6570/base/ubuntu-20.04:2 AS bhb_base

LABEL maintainer="Surampudi Satyanarayana <surampudix.satyanarayana@intel.com>"

COPY .sideload/common/ltoken /var/downloads/
COPY .sideload/common/.gitconfig /var/downloads/.gitconfig
COPY .sideload/common/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY .sideload/cmake/cmake-3.15.7-Linux-x86_64.sh /opt/cmake.sh
ADD .sideload/klocwork/klocwork-20-server.tar.gz /var/downloads/klocwork/
ADD .sideload/klocwork/klocwork-20-cmd.tar.gz /var/downloads/klocwork-cmd/
ADD .sideload/arm/arm.tar.gz /var/downloads/arm/
ADD .sideload/xtensa/xtensa.tar.gz /var/downloads/xtensa/

ENV KLOCWORK_LICENSE_FILE "7500@klocwork05p.elic.intel.com:7500@klocwork03p.elic.intel.com"
ENV PATH "${PATH}:/opt/xtensa:/opt/arm"

RUN printf "%b\n" "---> Install CMAKE <--" && \
    mkdir /opt/cmake && \
    sh /opt/cmake.sh --prefix=/opt/cmake --skip-license && \
    chown -R root /opt/cmake && \
    ln -sfn /opt/cmake/bin/ccmake /usr/local/bin/ccmake && \
    ln -sfn /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    ln -sfn /opt/cmake/bin/cmake-gui /usr/local/bin/cmake-gui && \
    ln -sfn /opt/cmake/bin/cpack /usr/local/bin/cpack && \
    ln -sfn /opt/cmake/bin/ctest /usr/local/bin/ctest && \
    printf "%b\n" "---> Install Klocwork <---" && \
    mv /var/downloads/klocwork /opt/ && chown -R root /opt/klocwork && \
    mv /var/downloads/klocwork-cmd /opt/ && chown -R root /opt/klocwork-cmd && \
    printf "%b\n" "---> Install Dependencies <---" && \
    mv /var/downloads/arm /opt/ && chown -R root /opt/arm && \
    mv /var/downloads/xtensa /opt/ && chown -R root /opt/xtensa && \
    printf "%b\n" "---> Update and Install Packages <---" && \
    apt update && apt full-upgrade -y && \
    apt install -y apt-utils nano \
    libargtable2-0 libargtable2-dev \
    libcairo2 libcairo2-dev libcairo-gobject2 \
    libcairo-perl libcairo-gobject-perl \
    libcairo-script-interpreter2 libcairomm-1.0-1v5 \
    libcairo2:i386 libhidapi-dev \
    libhidapi-hidraw0 libhidapi-libusb0 \
    libusb-0.1-4:i386 gcc-multilib g++-multilib \
    llvm llvm-dev llvm-runtime \
    llvm-8 llvm-8-dev llvm-8-tools llvm-8-runtime \
    lld-8 liblld-8 liblld-8-dev \
    clang libclang-dev clang-tools clang-format \
    clang-8 libclang-8-dev clang-tools-8 clang-format-8 \
    ssh-import-id ninja-build \
    python-dev python-numpy python-numpy-dev \
    python3-pip python3-setuptools \
    python3-wheel python3-dev python3-pytest \
    python3-numpy python3-numpy-dev && \
    apt remove cmake -y && apt autoremove -y && \
    apt clean && apt autoclean && \
    pip install pytest==3.3.2 && \
    pip install --upgrade attrs==19.1.0 && \
    ln -s /usr/lib/llvm-8/bin/ld.lld /usr/bin/ld.lld
Run \
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


# This causes this script to be executed before any other command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
