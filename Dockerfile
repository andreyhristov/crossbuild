FROM buildpack-deps:stretch-curl
MAINTAINER Manfred Touron <m@42.am> (https://github.com/moul)

# Install deps
RUN set -x; \
    echo deb http://emdebian.org/tools/debian/ stretch main > /etc/apt/sources.list.d/emdebian.list \
 && curl -sL http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
 && dpkg --add-architecture arm64                      \
 && apt-get update                                     \
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
    CROSS_TRIPLE=x86_64-linux-gnu

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
