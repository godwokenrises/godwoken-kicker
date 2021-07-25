ARG DOCKER_PREBUILD_IMAGE 
FROM ${DOCKER_PREBUILD_IMAGE} 
USER root

RUN if [ "$MANUAL_BUILD_WEB3" = true ] ; then \
        cd /code/packages/godwoken-web3 ;\
    else \
        cd /godwoken-web3 ;\
fi

EXPOSE 8024

CMD ["node", "version"]
