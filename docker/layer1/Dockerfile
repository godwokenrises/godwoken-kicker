# FROM nervos/ckb
# USER root
# 
# ENV CKB_CHAIN=dev
# ENV BA_ARG=0x839f6f4d6fdf773d3e015f8b19fe5c4ccb07723d
# ENV BA_CODE_HASH=0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8
# ENV BA_HASH_TYPE=type
# ENV BA_MESSAGE=0x1234
# 
# COPY entrypoint.sh entrypoint.sh
# 
# EXPOSE 8114 8115
# 
# WORKDIR /code
# RUN ckb init -c dev -C godwoken-test1
# WORKDIR godwoken-test1
# COPY ckb-miner.toml ckb-miner.toml
# COPY ckb.toml ckb.toml
# COPY specs/dev.toml specs/dev.toml
# 
# 
# 
# ENTRYPOINT ["./entrypoint.sh"]

#CMD [ "run", "&" ]
#RUN sleep 5
#CMD [ "miner", "&"]

FROM nervos/ckb

USER root

ENV CKB_CHAIN=dev
ENV BA_ARG=0x43d509d97f26007a285f39241cffcd411157196c
ENV BA_CODE_HASH=0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8
ENV BA_HASH_TYPE=type
ENV BA_MESSAGE=0x1234

EXPOSE 8114 8115
WORKDIR /code
COPY --chown=ckb ./entrypoint.sh /bin/

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
