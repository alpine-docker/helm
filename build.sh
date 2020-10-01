#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# set -ex

build() {
  
  
  if [[ ${ARCH} == 'x86_64' ]]; then ARCH=amd64; fi
  echo "Found new version, building the image ${image}:${tag}-${ARCH}"
  docker build --no-cache --build-arg VERSION=${tag} --build-arg ARCH=${ARCH} -t ${image}:${tag}-${ARCH} .

  # run test
  version=$(docker run --rm ${image}:${tag}-${ARCH} version --client)
  #Client: &version.Version{SemVer:"v2.9.0-rc2", GitCommit:"08db2d0181f4ce394513c32ba1aee7ffc6bc3326", GitTreeState:"clean"}
  if [[ "${version}" == *"Error: unknown flag: --client"* ]]; then
    echo "Detected Helm3+"
    version=$(docker run --rm ${image}:${tag}-${ARCH} version)
    #version.BuildInfo{Version:"v3.0.0-beta.2", GitCommit:"26c7338408f8db593f93cd7c963ad56f67f662d4", GitTreeState:"clean", GoVersion:"go1.12.9"}
  fi
  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${tag}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${tag}-${ARCH}
  fi
}

image="alpine/helm"
repo="helm/helm"
ARCH=$(uname -m)

latest=`curl -sL https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|sort -Vr|sed 's/^v//' | head -1`
for tag in ${latest}
do
  echo $tag
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag}-${ARCH})
  echo $status
  if [[ "${status}" =~ "not found" ]]; then
    build
  fi
done
