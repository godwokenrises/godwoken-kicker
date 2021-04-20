FROM retricsu/gowoken-build_dev

USER root

EXPOSE 8116
WORKDIR /code

COPY --chown=root ./indexer_entrypoint.sh /bin/
RUN chmod +x /bin/indexer_entrypoint.sh

ENTRYPOINT ["/bin/indexer_entrypoint.sh"]
