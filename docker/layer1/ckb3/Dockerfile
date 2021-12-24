ARG DOCKER_PREBUILD_IMAGE 
FROM ${DOCKER_PREBUILD_IMAGE}

USER root

EXPOSE 6117 6118
WORKDIR /code
COPY ./entrypoint.sh /bin/

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
