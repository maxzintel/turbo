FROM node:10-alpine

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY server.js server.js

RUN apk add curl \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && trivy filesystem --exit-code 0 --severity MEDIUM,HIGH --no-progress /

RUN npm install redis@2.8.0

CMD node server.js
