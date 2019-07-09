# kubernetes helm

Auto-trigger docker build for [kubernetes helm](https://github.com/kubernetes/helm) when new release is announced

## NOTES

The latest docker tag is the latest verison, picked up from all latest releases, rc and alpha (pre-release) versions. 

Please avoid to use `latest` tag for any production deployment. Tag with right version is the proper way, such as `alpine/helm:2.14.0`

### Github Repo

https://github.com/alpine-docker/helm

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/helm

### Docker image tags

https://hub.docker.com/r/alpine/helm/tags/

# Usage

    # must mount the local folder to /apps in container.
    docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm alpine/helm

    # Run helm with special version. The tag is helm's version
    docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm alpine/helm:2.12.1

    # run container as command
    alias helm="docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm alpine/helm"
    helm --help
    
    # example in ~/.bash_profile
    alias helm='docker run -e KUBECONFIG="/root/.kube/config:/root/.kube/some-other-context.yaml" -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm alpine/helm'

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# The Processes to build this image

* Enable Travis CI cronjob on this repo to run build daily on master branch
* Check if there are new tags/releases announced via Github REST API
* Match the exist docker image tags via Hub.docker.io REST API
* If not matched, build the image with latest version as tag and push to hub.docker.com
