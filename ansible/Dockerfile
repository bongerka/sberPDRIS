FROM alpine
RUN apk add --no-cache openssh-client ansible git sshpass
COPY . /ansible

WORKDIR /ansible

CMD ["/bin/sh"]
