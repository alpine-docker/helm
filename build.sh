#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

# set -ex

set -e

install_jq() {
  # jq 1.6
  DEBIAN_FRONTEND=noninteractive
  #sudo apt-get update && sudo apt-get -q -y install jq
  curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
  sudo mv jq /usr/bin/jq
  sudo chmod +x /usr/bin/jq
}

build() {

  docker build --no-cache \
    --build-arg VERSION=${tag} \
    -t ${image}:${tag} .

  # run test
  echo "Detected Helm3+"
  version=$(docker run --rm ${image}:${tag} version)
  # version.BuildInfo{Version:"v3.6.3", GitCommit:"d506314abfb5d21419df8c7e7e68012379db2354", GitTreeState:"clean", GoVersion:"go1.16.5"}

  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${tag}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  # install crane
  curl -LO https://github.com/google/go-containerregistry/releases/download/v0.11.0/go-containerregistry_Linux_x86_64.tar.gz
  tar zxvf go-containerregistry_Linux_x86_64.tar.gz
  chmod +x crane

  if [[ "$CIRCLE_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker buildx create --use
    docker buildx build --no-cache --push \
      --platform=linux/amd64,linux/arm/v7,linux/arm64/v8,linux/arm/v6,linux/ppc64le,linux/s390x \
      --build-arg VERSION=${tag} \
      -t ${image}:${tag} .

  ./crane copy ${image}:${tag} ${image}:latest

  fi
}

image="alpine/helm"

install_jq

# Get the list of all releases tags, excludes alpha, beta, rc tags
tag=$(curl -s https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name | select(test("alpha|beta|rc") | not) ' \
    | sort -rV | head -n 1 |sed 's/v//')

echo "Found helm latest version: ${tag}"

status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
echo $status
if [[ ( "${status}" =~ "not found" ) ||( ${REBUILD} == "true" ) ]]; then
   echo "build image for ${tag}"
   build
fi
