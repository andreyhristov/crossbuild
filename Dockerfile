FROM ubuntu:xenial

# Install deps
RUN set -x; \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial main restricted" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64]  http://ports.ubuntu.com/ubuntu-ports/ xenial universe" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates universe" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial multiverse" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates multiverse" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-security main restricted" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-security universe" >> /etc/apt/sources.list && \
	echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ xenial-security multiverse" >> /etc/apt/sources.list && \
	apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5 && \
	apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32 && \
	apt-get update                                     \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        autoconf                                       \
        automake                                       \
        autotools-dev                                  \
        binfmt-support                                 \
        binutils-multiarch                             \
        binutils-multiarch-dev                         \
        build-essential                                \
        clang                                          \
        crossbuild-essential-arm64                     \
        curl                                           \
        devscripts                                     \
        gdb                                            \
        git-core                                       \
        libtool                                        \
        llvm                                           \
        multistrap                                     \
        patch                                          \
        software-properties-common                     \
        wget                                           \
        xz-utils                                       \
        qemu-user-static                               \
 && apt-get clean

# Create symlinks for triples and set default CROSS_TRIPLE
ENV LINUX_TRIPLES=aarch64-linux-gnu                  \
    CROSS_TRIPLE=aarch64-linux-gnu

RUN for triple in $(echo ${LINUX_TRIPLES} | tr "," " "); do                                       \
      for bin in /etc/alternatives/$triple-* /usr/bin/$triple-*; do                               \
        if [ ! -f /usr/$triple/bin/$(basename $bin | sed "s/$triple-//") ]; then                  \
          ln -s $bin /usr/$triple/bin/$(basename $bin | sed "s/$triple-//");                      \
        fi;                                                                                       \
      done;                                                                                       \
    done
# Image metadata
ENTRYPOINT ["/usr/bin/crossbuild"]
CMD ["/bin/bash"]
WORKDIR /workdir
COPY ./assets/crossbuild /usr/bin/crossbuild
