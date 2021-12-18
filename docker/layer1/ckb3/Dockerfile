ARG DOCKER_PREBUILD_IMAGE 
FROM ${DOCKER_PREBUILD_IMAGE}

USER root

RUN apt-get update && \
    apt-get install iproute2 iputils-ping -y

EXPOSE 6117 6118
WORKDIR /code
COPY ./entrypoint.sh /bin/

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
