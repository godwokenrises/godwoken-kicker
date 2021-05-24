FROM nervos/godwoken-prebuilds:v0.2.3

USER root

ENV CKB_CHAIN=dev
ENV BA_ARG=0x43d509d97f26007a285f39241cffcd411157196c
ENV BA_CODE_HASH=0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8
ENV BA_HASH_TYPE=type
ENV BA_MESSAGE=0x1234

EXPOSE 8114 8115
WORKDIR /code
COPY ./entrypoint.sh /bin/

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
