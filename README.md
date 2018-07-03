# helm - DRAFT
Auto-trigger docker build for [kubernetes helm](https://github.com/kubernetes/helm) when new release is announced

### Repo:

https://github.com/alpine-docker/helm

### Daily build logs:

https://travis-ci.org/alpine-docker/helm

### Docker iamge tags:

https://hub.docker.com/r/alpine/helm/tags/

# Usage:

    # must mount the local folder to /apps in container.
    docker run -ti --rm -v $(pwd):/apps -v ~/.kube/config:/root/.kube/config alpine/helm:2.9.0

    # run terraform-landscape container as command
    alias helm="docker run -ti --rm -v $(pwd):/apps -v ~/.kube/config:/root/.kube/config alpine/helm:2.9.0"
    help --help


# A complex use-case.

Surpose you need run with kubectl and heptio as well to access AWS EKS Cluster. kubectl and heptio must be downloaded for Linux version.

>docker run -ti --rm -v ~/.kube/config:/root/.kube/config -e AWS_SESSION_TOKEN=xxx -e AWS_SECRET_ACCESS_KEY=xxx -e AWS_ACCESS_KEY_ID=xxx -e AWS_REGION=us-west-2 -v /usr/bin/heptio-authenticator-aws:/usr/bin/heptio-authenticator-aws -v /usr/bin/kubectl:/usr/bin/kubectl --entrypoint=sh alpine/helm:2.9.0

# Why use it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest version as tag and push to hub.docker.com
