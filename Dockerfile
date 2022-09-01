FROM python:alpine
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh && \
    pip install hatch
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
