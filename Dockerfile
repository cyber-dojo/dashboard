FROM cyberdojo/sinatra-base:16c1478
LABEL maintainer=jon@jaggersoft.com

WORKDIR /dashboard
COPY source/server .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /dashboard/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/dashboard/config/up.sh" ]
