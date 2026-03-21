FROM ghcr.io/cyber-dojo/sinatra-base:3ce6c9b@sha256:7e53acc4239e11722997e85367eb8e995d995ceec05f1cc6430da989bb09b108
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade openssl=3.5.5-r0 # https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-15121113
RUN apk add --upgrade c-ares=1.34.6-r0 # https://security.snyk.io/vuln/SNYK-ALPINE322-CARES-14409293

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/dashboard
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY source/server/ .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["./config/up.sh"]
