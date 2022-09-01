FROM python:alpine
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh && \
    pip install hatch && \
    git config --global --add safe.directory /github/workspace && \
    git config --global user.name 'autobump' && \
    git config --global user.email 'autobump@users.noreply.github.com'
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
