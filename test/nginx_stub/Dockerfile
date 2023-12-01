FROM nginx:latest
LABEL maintainer=jon@jaggersoft.com

ARG NGINX_DIR=/usr/share/nginx/html

COPY images ${NGINX_DIR}/images
COPY js     ${NGINX_DIR}/js

RUN chmod -R +r ${NGINX_DIR}

COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

RUN echo ${SHA} > ${NGINX_DIR}/sha.txt
