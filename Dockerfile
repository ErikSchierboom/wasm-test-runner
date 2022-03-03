FROM node:16-bullseye-slim as runner
# Node.js 16 (curently LTS)
# Debian bullseye

# fetch latest security updates
# jq is needed to read JSON configuration files
RUN set -ex && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install jq -y && \
    rm -rf /var/lib/apt/lists/*

# add a non-root user to run our code as
RUN adduser --disabled-password --gecos "" appuser

RUN yarn set version classic

# install our test runner to /opt
WORKDIR /opt/test-runner

# install all the development modules (used for building)
COPY . .
RUN yarn install
RUN yarn build

# install only the node_modules we need for production
RUN rm -rf node_modules && yarn install --production && yarn cache clean

USER appuser
ENTRYPOINT [ "/opt/test-runner/bin/run.sh" ]
