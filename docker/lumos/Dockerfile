FROM huwenchao/godwoken:dev
WORKDIR /code
COPY . .
RUN ls
RUN git checkout v0.14.2-rc6
RUN yarn
WORKDIR packages/sql-indexer
COPY knexfile.js knexfile.js
CMD [ "npx", "knex", "migrate:up" ]