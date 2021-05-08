# not used now
FROM nervos/godwoken-prebuilds:v0.2.0-rc2

WORKDIR /runner
COPY ../../godwoken-examples/packages/runner/package*.json ./
RUN npm install
RUN ls

COPY ../../godwoken-examples/packages/runner ./

EXPOSE 6101
EXPOSE 6100
CMD ["npm", "start:clean"]