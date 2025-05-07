FROM cyberdojo/sinatra-base:0357618@sha256:3c4f92eb282f4dee797b37b703f6c4de0471eaebe94beec5ddb804cbade046be
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /dashboard
COPY source/server .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /dashboard/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/dashboard/config/up.sh" ]
