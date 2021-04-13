FROM nervos/ckb-riscv-gnu-toolchain:xenial
WORKDIR /code
COPY always_success.S /code/always_success.S
RUN echo 'test hello' > test.txt
RUN riscv64-unknown-elf-gcc -o deposition_lock always_success.S -nostartfiles -nostdlib
RUN riscv64-unknown-elf-gcc -o custodian_lock always_success.S -nostartfiles -nostdlib
RUN riscv64-unknown-elf-gcc -o withdrawal_lock always_success.S -nostartfiles -nostdlib
RUN riscv64-unknown-elf-gcc -o state_validator_lock always_success.S -nostartfiles -nostdlib
RUN riscv64-unknown-elf-gcc -o state_validator_type always_success.S -nostartfiles -nostdlib
#COPY . /code
#COPY . .
RUN ls
CMD ["ls"]
#CMD ["riscv64-unknown-elf-gcc -o state_validator_lock always_success.S -nostartfiles -nostdlib"]
RUN exit
