ARG BASE_IMAGE=cyberdojo/sinatra-base:d6def8c
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

WORKDIR /dashboard
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /dashboard/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/dashboard/config/up.sh" ]
