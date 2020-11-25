FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DASHBOARD_PORT
ENV PORT=${CYBER_DOJO_DASHBOARD_PORT}

EXPOSE ${PORT}
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /app/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/up.sh" ]
