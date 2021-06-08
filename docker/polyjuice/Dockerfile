ARG DOCKER_PREBUILD_IMAGE 
FROM ${DOCKER_PREBUILD_IMAGE} 
USER root

RUN if [ "$MANUAL_BUILD_POLYMAN" = true ] ; then \
        cd /code/godwoken-polyman ;\
        yarn init_placeholder_config ;\
    else \
        cd /godwoken-polyman ;\
        yarn init_placeholder_config ;\
fi

EXPOSE 8024

CMD ["node", "version"]
