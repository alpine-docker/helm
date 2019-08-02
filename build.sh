#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

Usage() {
  echo "$0"
}

build() {
  BUILD_TAG=$1

  docker build --no-cache --build-arg VERSION=${BUILD_TAG} -t ${image}:${BUILD_TAG} .

  # test
  version=$(docker run -ti --rm ${image}:${BUILD_TAG} version )
  #Client: &version.Version{SemVer:"v2.9.0-rc2", GitCommit:"08db2d0181f4ce394513c32ba1aee7ffc6bc3326", GitTreeState:"clean"}
  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${BUILD_TEST}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${BUILD_TAG}
  fi
}

image="alpine/helm"
repo="helm/helm"

if [[ ${CI} == 'true' ]]; then
  CURL="curl -sL -H \"Authorization: token ${API_TOKEN}\""
else
  CURL="curl -sL"
fi

latest=`${CURL} https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|head -10|sed 's/^v//'`
echo "Lastest releases are: ${latest}"

for tag in ${latest}
do
  echo $tag
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ "${status}" =~ "Not found" ]]; then
    build ${tag}
  fi
done
