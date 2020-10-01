FROM alpine:3

# variable "VERSION" & "ARCH" must be passed as docker environment variables during the image build
# docker build --no-cache --build-arg VERSION=2.12.0 ARCH=amd64 -t alpine/helm:2.12.0 .

ARG VERSION
ARG ARCH

# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${VERSION}-linux-${ARCH}.tar.gz"

RUN apk add --update --no-cache curl ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH} && \
    apk del curl && \
    rm -f /var/cache/apk/*

WORKDIR /apps

ENTRYPOINT ["helm"]
CMD ["--help"]
