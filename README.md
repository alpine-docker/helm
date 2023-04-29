# kubernetes helm

[If enjoy, please consider buying me a coffee.](https://www.buymeacoffee.com/ozbillwang)

Auto-trigger docker build for [kubernetes helm](https://github.com/kubernetes/helm) when new release is announced

[![DockerHub Badge](http://dockeri.co/image/alpine/helm)](https://hub.docker.com/r/alpine/helm/)

Circle CI - [![CircleCI](https://circleci.com/gh/alpine-docker/helm.svg?style=svg)](https://circleci.com/gh/alpine-docker/helm)

## NOTES

The latest docker tag is the latest release version (https://github.com/helm/helm/releases/latest)

Please avoid to use `latest` tag for any production deployment. Tag with right version is the proper way, such as `alpine/helm:3.11.1`

If you need run `kubectl` with `helm` together, please use another image [alpine/k8s](https://github.com/alpine-docker/k8s)

## Additional notes about multi-arch images

This feature was added on 23th May 2021.

1. Versions 3.5.4 and 3.6.0-rc.1 have been manually pushed with support for multi-arch images.
2. Older versions will not be updated to support multi-arch images.
3. Newer versions going forward will support multi-arch images, including: `--platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/arm/v6,linux/ppc64le,linux/s390x`.
4. I do not support other architectures besides amd64 since I do not have the necessary environments to test them. If you experience any issues with other platforms, please raise a PR to fix it.
5. There is no difference in running `docker pull` and `docker run` commands with multi-arch docker images; you can run them as normal. For example, if you need to pull an image from arm64 (such as the new Mac M1 chip), you can run `docker pull alpine/helm:3.5.4` to get the image directly. Remember to specify the desired version number.

### Github Repo

https://github.com/alpine-docker/helm

### CI build logs

https://app.circleci.com/pipelines/github/alpine-docker/helm?branch=master

### Docker image tags

https://hub.docker.com/r/alpine/helm/tags/

# Usage

    # mount local folders in container.
    docker run -ti --rm -v $(pwd):/apps -w /apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        -v ~/.cache/helm:/root/.cache/helm \
        alpine/helm

    # Run helm with special version. The tag is helm's version
    docker run -ti --rm -v $(pwd):/apps -w /apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        -v ~/.cache/helm:/root/.cache/helm \
        alpine/helm:3.1.1

    # run container as command
    alias helm="docker run -ti --rm -v $(pwd):/apps -w /apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        -v ~/.cache/helm:/root/.cache/helm \
        alpine/helm"
    helm --help
    
    # example in ~/.bash_profile
    alias helm='docker run -e KUBECONFIG="/root/.kube/config:/root/.kube/some-other-context.yaml" -ti --rm -v $(pwd):/apps -w /apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        -v ~/.cache/helm:/root/.cache/helm \
        alpine/helm'

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# The Processes to build this image

* Enable CI cronjob on this repo to run build regularly on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with release version and push to https://hub.docker.com/
