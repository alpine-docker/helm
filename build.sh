#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

set -ex

build() {

  echo "Found new version, building the image ${image}:${tag}"
  docker build --no-cache --build-arg VERSION=${tag} -t ${image}:${tag} .

  # run test
  version=$(docker run -ti --rm ${image}:${tag} version --client)
  #Client: &version.Version{SemVer:"v2.9.0-rc2", GitCommit:"08db2d0181f4ce394513c32ba1aee7ffc6bc3326", GitTreeState:"clean"}
  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${tag}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${tag}
  fi
}

image="alpine/helm"
repo="helm/helm"

if [[ ${CI} == 'true' ]]; then
  latest=`curl -sL -H "Authorization: token ${API_TOKEN}"  https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|sort -Vr|head -10|sed 's/^v//'`
else
  latest=`curl -sL https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|sort -Vr|head -10|sed 's/^v//'`
fi

for tag in ${latest}
do
  echo $tag
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ "${status}" =~ "Not found" ]]; then
    build
  fi
done

echo "Update latest image with latest release"
# output format for reference:
# <html><body>You are being <a href="https://github.com/helm/helm/releases/tag/v2.14.3">redirected</a>.</body></html>
latest=$(curl -s https://github.com/${repo}/releases/latest)
latest=$(echo $latest\" |grep -oP '(?<=tag\/v)[0-9][^"]*')
echo $latest

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker pull ${image}:${latest}
  docker tag ${image}:${latest} ${image}:latest
  docker push ${image}:latest
fi
