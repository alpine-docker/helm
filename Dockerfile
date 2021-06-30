FROM alpine:3

# variable "VERSION" must be passed as docker environment variables during the image build
# docker build --no-cache --build-arg VERSION=2.12.0 -t alpine/helm:2.12.0 .

ARG VERSION

# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"

RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    apk add --update --no-cache curl ca-certificates wget && \
    curl -L ${BASE_URL}/helm-v${VERSION}-linux-${ARCH}.tar.gz |tar xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH} && \
    apk del curl && \
    rm -f /var/cache/apk/*

WORKDIR /apps

ENTRYPOINT ["helm"]
CMD ["--help"]
