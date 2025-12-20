FROM ghcr.io/cyber-dojo/sinatra-base:afd3580@sha256:9f037f66b3edc6b644d688d76a5cf624ab60751f0b14947de1237686c5776b1f
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

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
