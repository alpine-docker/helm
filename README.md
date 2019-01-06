# kubernetes helm
Auto-trigger docker build for [kubernetes helm](https://github.com/kubernetes/helm) when new release is announced

### Repo:

https://github.com/alpine-docker/helm

### Daily build logs:

https://travis-ci.org/alpine-docker/helm

### Docker iamge tags:

https://hub.docker.com/r/alpine/helm/tags/

# Usage:

    # must mount the local folder to /apps in container.
    docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube alpine/helm

    # run container as command
    alias helm="docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube alpine/helm"
    helm --help
    
    # example in ~/.bash_profile
    alias helm='docker run -e KUBECONFIG="/root/.kube/config:/root/.kube/some-other-context.yaml" -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube alpine/helm'

# Why use it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest version as tag and push to hub.docker.com
