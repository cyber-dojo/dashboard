FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

COPY --chown=nobody:nogroup . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DASHBOARD_PORT
ENV PORT=${CYBER_DOJO_DASHBOARD_PORT}
EXPOSE ${PORT}

USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/up.sh" ]
