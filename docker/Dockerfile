FROM ubuntu:20.04
USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt install libssl-dev libsodium-dev libunwind-dev build-essential binutils upx curl wget -y && \
    DEBIAN_FRONTEND=noninteractive apt install rustc -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install cmake musl-tools clang libc++-dev autoconf libtool pkg-config -y


# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2020-09-28 -y
ENV PATH=/root/.cargo/bin:$PATH
RUN which cargo

RUN curl -sL https://deb.nodesource.com/setup_12.x  | DEBIAN_FRONTEND=noninteractive bash -
RUN apt install -y nodejs

RUN npm install -g yarn

# install tools
RUN yarn global add ts-node-dev typescript
# RUN cargo install ckb-capsule
RUN cargo install moleculec --version 0.6.1
RUN echo $HOME 
RUN moleculec --version
# RUN curl http://security.ubuntu.com/ubuntu/pool/main/g/gcc-10/libgcc-s1_10-20200411-0ubuntu1_amd64.deb --output libgcc-s1_10-20200411-0ubuntu1_amd64.deb && dpkg -i libgcc-s1_10-20200411-0ubuntu1_amd64.deb
RUN curl http://ftp.br.debian.org/debian/pool/main/g/glibc/libc6_2.31-11_amd64.deb --output libc6_2.31-11_amd64.deb && dpkg -i libc6_2.31-11_amd64.deb 

RUN mkdir -p .ckb
RUN wget -c https://github.com/nervosnetwork/ckb-cli/releases/download/v0.41.0/ckb-cli_v0.41.0_x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz
RUN cd ckb-cli_v0.41.0_x86_64-unknown-linux-gnu
RUN cp /ckb-cli_v0.41.0_x86_64-unknown-linux-gnu/ckb-cli /usr/bin/ckb-cli
ENV PATH="/usr/bin/ckb-cli:${PATH}"