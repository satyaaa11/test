FROM af01p-fm.devtools.intel.com:6570/upstream/ubuntu:20.04

LABEL maintainer="NPSG CDE DevOps Team <npsg.devops.cde@intel.com>"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    export DEBIAN_FRONTEND="noninteractive" && \
    apt-get install -y \
    # general
    tzdata \
    apt-utils \
    apt-transport-https \
    lsb \
    rename \
    git \
    curl \
    wget \
    software-properties-common \
    unzip \
    sudo \
    nfs-common \
    # base support
 	gcc-8-base \ 
	libnuma-dev \
	libperl4-corelibs-perl \
	libssl-dev \
	libunwind-dev \
	nfs-common \
	pciutils \
	pycodestyle \
	python3.8 \
	python3.8-dev \
	python3-pip \
	python3-setuptools \
	sudo \
	xxd \
	# general build
	build-essential \
	# file sharing
	cifs-utils \
	# python 2.x is deprecated and not installed by default
	python2.7 \
	python-is-python2 \
	python2-dev \
	# Pip
	python3-pip \
	# cmake 3.16 is available in the repo
	cmake \
	# ninja
	ninja-build \
    # forward
	clang-10 \
	clang-10-doc \
	clang-tidy-10 \
	clang-format-10 \
	clang-tools-10 \
	llvm-10 \
	llvm-10-doc \
	lld-10 \
	# current
	clang-8 \
	clang-tidy-8 \
	clang-format-8 \
	clang-tools-8 \
	llvm-8 \
	llvm-8-doc \
	lld-8 \
	lldb-8 \
	# debug
	lcov \
	# support for build
	libisal2 \
	libisal-dev \
	isal \
	nasm \
	libboost-all-dev \
	libpci-dev \
	# other
	binutils-multiarch \
	libargtable2-0 \
	libargtable2-dev \
	libusb-0.1.4 \
	libcunit1-dev \
	librdmacm-dev \
	gcc-multilib \
	gdb-multiarch  \
	devmem2 \
	uuid-dev \
	# documentation - almost all build types (FW/simulator) need this
	doxygen \
	plantuml && \
	curl -fsSL https://apt.llvm.org/llvm.sh | bash -s 12 && \
	apt-get install clang-12-doc clang-format-12 clang-tools-12 libclang-12-dev clang-tidy-12 && \
    apt-get autoremove -y && apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    printf "%b\n" "--> Install Certificates <--" && \
    wget -P /tmp http://certificates.intel.com/repository/certificates/Public%20Root%20Certificate%20Chain%20Base64.zip && \
    wget -P /tmp http://certificates.intel.com/repository/certificates/PublicSHA2RootChain-Base64-crosssigned.zip && \
    unzip /tmp/Public\ Root\ Certificate\ Chain\ Base64.zip -d /usr/local/share/ca-certificates/ && \
    unzip /tmp/PublicSHA2RootChain-Base64-crosssigned.zip -d /usr/local/share/ca-certificates/ && \
    curl http://certificates.intel.com/repository/certificates/IntelSHA256RootCA-Base64.crt -o /usr/local/share/ca-certificates/IntelSHA256RootCA-Base64.crt && \
    # Certificate file names cannot contain spaces or special characters. Also change .cer extensions to .crt
    cd /usr/local/share/ca-certificates/ && \
    rename 's/[^A-Za-z0-9._-]/_/g' * && \
    rename "s/cer$/crt/" *.cer && \
    update-ca-certificates && \
    printf "%b\n" "--> Install Python2 Pip <--" && \
    curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py && \
    # dumb-init enables proper signal handling in docker
    # gosu is used for running commands as a different user
    printf "%b\n" "--> Install Dumb-init and Gosu <--" && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    chmod +x /usr/local/bin/gosu && \
    printf "%b\n" "--> Cleanup <--" && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
    ln -sf /usr/lib/llvm-8/bin/ld.lld /usr/bin/ld.lld

ADD configs /

RUN python3 -m pip install -r /requirements.txt.3 && rm -f /requirements.txt.3 && \
    python2 -m pip install -r /requirements.txt.2 && rm -f /requirements.txt.2 && \
    printf "%b\n" "--> Setting permissions <--" && \
    chmod 0755 /usr/local/bin/entrypoint.sh && \
    chmod 0644 /etc/profile.d/proxy.sh && \
    chmod 0644 /var/config/defaulthome/.bashrc && \
    chmod 0644 /var/config/defaulthome/.bash_aliases && \
    chmod 0644 /var/config/defaulthome/.git-completion.bash && \
    chmod 0644 /var/config/defaulthome/.gitconfig && \
    chmod 0644 /etc/apt/sources.list && \
    chmod 0644 /etc/apt/apt.conf.d/00proxy

# This causes this script to be executed before any other command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
