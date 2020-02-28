# kubernetes helm

Auto-trigger docker build for [kubernetes helm](https://github.com/kubernetes/helm) when new release is announced

[![DockerHub Badge](http://dockeri.co/image/alpine/helm)](https://hub.docker.com/r/alpine/helm/)

## NOTES

The latest docker tag is the latest release verison (https://github.com/helm/helm/releases/latest)

Please avoid to use `latest` tag for any production deployment. Tag with right version is the proper way, such as `alpine/helm:3.1.1`

### Github Repo

https://github.com/alpine-docker/helm

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/helm

### Docker image tags

https://hub.docker.com/r/alpine/helm/tags/

# Usage

    # must mount the local folder to /apps in container.
    docker run -ti --rm -v $(pwd):/apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        alpine/helm

    # Run helm with special version. The tag is helm's version
    docker run -ti --rm -v $(pwd):/apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        alpine/helm:3.1.1

    # run container as command
    alias helm="docker run -ti --rm -v $(pwd):/apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        alpine/helm"
    helm --help
    
    # example in ~/.bash_profile
    alias helm='docker run -e KUBECONFIG="/root/.kube/config:/root/.kube/some-other-context.yaml" -ti --rm -v $(pwd):/apps \
        -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm \
        alpine/helm'

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with release version and push to https://hub.docker.com/
* Get the latest version from https://github.com/helm/helm/releases/latest, pull the image with that version, tag as `alpine/helm:latest` and push to hub.docker.com
