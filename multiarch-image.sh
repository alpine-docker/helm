#!/usr/bin/env bash
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

set -e

function get_arch_images(){
    image=$1; shift || fatal "usage error"
    tag=$1; shift || fatal "usage error"
	archs="amd64 ppc64le"
    for arch in $archs; 
	do
        if [[ "$(docker pull ${image}:${tag}-${arch} >/dev/null 2>&1 ; echo $?)" == 0 ]]; then
        	echo "${image}:${tag}-${arch} "
	fi
    done
}

image="alpine/helm"
repo="helm/helm"

if [[ "$TRAVIS_BRANCH" == "master" && "$TRAVIS_PULL_REQUEST" == false ]]; then	
	tags=`curl -sL https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|sort -Vr|sed 's/^v//' | head -1` 
	for tag in ${tags}
		do
			status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag}-amd64)
			echo $status
			if [[ ! "${status}" =~ "not found" ]]; then
				docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
				echo "Helm Version is $tag"
				DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest create ${image}:${tag} $(get_arch_images ${image} ${tag})
				DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest push --purge ${image}:${tag}
				DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest create ${image}:latest $(get_arch_images ${image} ${tag})
				DOCKER_CLI_EXPERIMENTAL="enabled" docker manifest push --purge ${image}:latest
			fi
	 	done
fi
