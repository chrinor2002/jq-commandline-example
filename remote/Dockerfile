FROM sickp/alpine-sshd:latest

RUN apk add mysql-client

RUN \
  passwd -d root && \
  adduser -D -s /bin/ash someuser && \
  passwd -u someuser && \
  chown -R someuser:someuser /home/someuser && \
  ssh-keygen -A
