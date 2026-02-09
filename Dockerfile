FROM ghcr.io/cyber-dojo/sinatra-base:71fcca8@sha256:8ff599728e607da61bf9237f8aa48d55eb0fd0df27205ed4a90e5f7b0626163e
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
