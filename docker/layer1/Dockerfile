FROM ghcr.io/zeroqn/godwoken-prebuilds:dev-feat-fast-withdrawal-to-v1.1 AS gw-v0

FROM ghcr.io/flouse/godwoken-prebuilds:1.2-gw-pull-721-merge-202206140118 AS gw-v1

FROM nervos/ckb:v0.103.0

USER root
RUN apt-get update \
 && apt-get install -y jq golang-github-pelletier-go-toml \
 && apt-get clean

USER ckb
COPY --from=gw-v0 /scripts/ /v0-scripts/
COPY --from=gw-v1 /scripts/ /v1-scripts/
COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
