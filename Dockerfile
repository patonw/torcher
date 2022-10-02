FROM rockylinux:9.0
ARG TORCH_DIST=https://download.pytorch.org/libtorch/cu113/libtorch-cxx11-abi-shared-with-deps-1.10.0%2Bcu113.zip

RUN curl https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox > /usr/bin/busybox \
    && chmod +x /usr/bin/busybox

RUN dnf -y group install "Development Tools" \
    && dnf -y install sudo git openssl-devel cmake \
    && dnf -y clean all

RUN groupadd -g 1001 people \
    && useradd -m -g 1001 -u 1000 user \
    && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user
WORKDIR /home/user

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN mkdir -p /opt \
    && busybox wget -c -q -O - $TORCH_DIST \
    | sudo busybox unzip -d /opt -

ENV LIBTORCH=/opt/libtorch LD_LIBRARY_PATH=/usr/local/cuda/lib64:/opt/libtorch/lib

ENTRYPOINT ["/bin/bash"]
