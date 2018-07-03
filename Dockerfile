FROM alpine:3.7

ARG HELM_VERSION=2.9.0
ENV URL="https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" 

RUN apk add --no-cache curl && \
    curl -L ${URL} |tar xvz && \
    cp linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    apk del curl

WORKDIR /apps

ENTRYPOINT ["helm"]
CMD ["--help"]
