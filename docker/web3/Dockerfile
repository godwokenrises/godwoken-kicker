FROM nervos/godwoken-prebuilds:v0.2.0-rc2

USER root

WORKDIR "/godwoken-web3"

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install jq -y \
 && apt-get clean \
 && echo "Finished installing dependencies"

# todo: should remove this for prebuild godwoken-web3
RUN yarn && yarn workspace @godwoken-web3/godwoken tsc

EXPOSE 8024

CMD ["node", "version"]
