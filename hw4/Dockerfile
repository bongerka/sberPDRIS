FROM alpine

RUN apk add openssh-server curl openrc go python3 gcc musl-dev

RUN openrc && touch /run/openrc/softlevel

RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
  && ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa

RUN echo "root:password" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
