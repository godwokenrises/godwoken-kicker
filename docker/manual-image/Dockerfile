FROM ubuntu:20.04

LABEL description="An all-in-one builder image for compiling Godwoken components"

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt install libssl-dev libsodium-dev libunwind-dev build-essential binutils upx curl wget -y && \
    DEBIAN_FRONTEND=noninteractive apt install rustc -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install cmake musl-tools clang libc++-dev autoconf libtool pkg-config unzip -y

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.54.0 -y
ENV PATH=/root/.cargo/bin:$PATH
RUN rustup component add rustfmt
RUN which cargo
RUN which rustfmt

# Install Capsule
RUN cargo install ckb-capsule
RUN which capsule

# install node 14
RUN curl -sL https://deb.nodesource.com/setup_14.x  | DEBIAN_FRONTEND=noninteractive bash -
RUN apt install -y nodejs
RUN npm install -g yarn

RUN cargo install moleculec --version 0.7.2
RUN echo $HOME 
RUN moleculec --version
#RUN curl http://ftp.br.debian.org/debian/pool/main/g/glibc/libc6_2.31-11_amd64.deb --output libc6_2.31-11_amd64.deb && dpkg -i libc6_2.31-11_amd64.deb 
RUN apt-get install libc6 -y

# install ckb tools
RUN mkdir /ckb
RUN cd /ckb && curl -LO https://github.com/nervosnetwork/ckb/releases/download/v0.100.0/ckb_v0.100.0_x86_64-unknown-linux-gnu.tar.gz
RUN cd /ckb && tar xzf ckb_v0.100.0_x86_64-unknown-linux-gnu.tar.gz

RUN mkdir /ckb-indexer
RUN cd /ckb-indexer && curl -LO https://github.com/nervosnetwork/ckb-indexer/releases/download/v0.3.0/ckb-indexer-0.3.0-linux.zip
RUN cd /ckb-indexer && unzip ckb-indexer-0.3.0-linux.zip && tar xzf ckb-indexer-linux-x86_64.tar.gz

RUN ls

RUN cp /ckb/ckb_v0.100.0_x86_64-unknown-linux-gnu/ckb /usr/bin/ckb
RUN cp /ckb/ckb_v0.100.0_x86_64-unknown-linux-gnu/ckb-cli /usr/bin/ckb-cli
RUN cp /ckb-indexer/ckb-indexer /usr/bin/ckb-indexer

RUN apt-get install jq -y \
 && echo "Finished installing dependencies"

CMD [ "node", "--version" ]
