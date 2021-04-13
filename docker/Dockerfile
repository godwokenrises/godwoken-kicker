FROM nervos/ckb-riscv-gnu-toolchain@sha256:aae8a3f79705f67d505d1f1d5ddc694a4fd537ed1c7e9622420a470d59ba2ec3

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2020-09-28 -y
ENV PATH=/root/.cargo/bin:$PATH

RUN curl -sL https://deb.nodesource.com/setup_12.x  | bash -
RUN apt install -y nodejs

RUN npm install -g yarn

# install tools
RUN yarn global add ts-node-dev typescript