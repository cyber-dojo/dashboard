FROM ghcr.io/cyber-dojo/sinatra-base:6d1262a@sha256:2282f8f00e03aeaf93e6ae5753c57986b3e6458325e354139b6315b239e81791 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

FROM cyberdojo/asset_builder:f2bcab7 AS assets
COPY source/server/app/assets/javascripts /app/app/assets/javascripts
COPY source/server/app/assets/stylesheets /app/app/assets/stylesheets
RUN /app/config/compile.sh /tmp/out

FROM base
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/dashboard
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY source/server/ .
COPY --from=assets /tmp/out/app.css /dashboard/assets/app.css
COPY --from=assets /tmp/out/app.js  /dashboard/assets/app.js
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["./config/up.sh"]
