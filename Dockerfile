FROM alpine:3.20

ENV SING_BOX_VERSION=1.11.15

RUN apk add --no-cache curl jq bash \
    && curl -L -o /tmp/sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz" \
    && mkdir -p /singbox \
    && tar -xzf /tmp/sing-box.tar.gz -C /singbox --strip-components=1 \
    && chmod +x /singbox/sing-box \
    && rm -rf /tmp/*

COPY config.template.json /singbox/config.template.json
COPY entrypoint.sh /entrypoint.sh

WORKDIR /singbox

ENTRYPOINT ["/entrypoint.sh"]
