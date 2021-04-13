FROM nervos/ckb-riscv-gnu-toolchain@sha256:aae8a3f79705f67d505d1f1d5ddc694a4fd537ed1c7e9622420a470d59ba2ec3
WORKDIR /code

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2020-09-28 -y
ENV PATH=/root/.cargo/bin:$PATH

RUN git clone --recursive https://github.com/nervosnetwork/godwoken.git
RUN cargo install moleculec --version 0.6.1
WORKDIR godwoken
RUN git checkout v0.1.x
RUN moleculec --language c --schema-file ./crates/types/schemas/godwoken.mol > ./c/build/godwoken.h
RUN moleculec --language c --schema-file ./crates/types/schemas/blockchain.mol > ./c/build/blockchain.h

# install node and npm yarn
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install 14.9.0 
RUN . "$NVM_DIR/nvm.sh" && nvm use 14.9.0
RUN . "$NVM_DIR/nvm.sh" && nvm alias default 14.9.0
ENV PATH="/root/.nvm/versions/node/v14.9.0/bin/:${PATH}"
RUN npm install -g yarn

WORKDIR c 

RUN echo 'from layer2' > l2.txt

RUN make all

WORKDIR godwoken 
RUN cargo build
RUN yarn

COPY . .

#COPY deposition_lock /code/c/godwoken/deposition_lock
#COPY deployment.json /code/c/godwoken/deployment.json
RUN ls
# COPY lumos-config.json lumos-config.json
# 
# RUN yarn workspace @ckb-godwoken/base tsc
# RUN yarn workspace @ckb-godwoken/tools tsc 
#     
# RUN LUMOS_CONFIG_FILE=lumos-config.json node packages/tools/lib/deploy_scripts.js --private-key 0xdd50cac37ec6dd12539a968c1a2cbedda75bd8724f7bcad486548eaabb87fc8b -f deployment.json -o deployment-results.json -s postgresql://user:password@postgres:5432/lumos
CMD [ "ls" ]
RUN exit
