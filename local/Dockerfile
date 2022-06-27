FROM bash

RUN apk add openssh

RUN \
  passwd -d root && \
  adduser -D -s /bin/ash someuser && \
  passwd -u someuser && \
  chown -R someuser:someuser /home/someuser && \
  ssh-keygen -A

USER someuser
WORKDIR /home/someuser
