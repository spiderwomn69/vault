FROM alpine:3.5
MAINTAINER 	Werner Dijkerman <ikben@werner-dijkerman.nl>

ENV VAULT_VERSION=0.6.4 \
    VAULT_USERNAME="vault" \
    VAULT_USERID=994

RUN apk --update --no-cache add curl tini libcap bash python openssl net-tools ca-certificates && \
    rm -rf /var/cache/apk/*

ADD run-vault.sh /bin/run-vault.sh

RUN adduser -D -u ${VAULT_USERID} ${VAULT_USERNAME} && \
    mkdir /vault /vault/ssl && \
    chown -R ${VAULT_USERNAME} /vault && \
    curl -sSLo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip -d /bin /tmp/vault.zip && \
    rm -rf /tmp/vault.zip && \
    chmod +x /bin/run-vault.sh /bin/vault && \
    setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

USER ${VAULT_USERNAME}

EXPOSE 8200
EXPOSE 8201
VOLUME /vault/ssl
VOLUME /vault
VOLUME /vault/audit

ENV VAULT_ADDR "https://127.0.0.1:8200"

ENTRYPOINT ["/sbin/tini", "--", "/bin/run-vault.sh"]
CMD []
