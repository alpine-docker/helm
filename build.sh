#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_USER
# API_TOKEN

set -ex

Usage() {
  echo "$0 [rebuild]"
}

image="alpine/helm"
repo="kubernetes/helm"

latest=`curl -sL -u ${API_USER}:${API_TOKEN}  https://api.github.com/repos/${repo}/tags |jq -r ".[].name"|head -1|sed 's/^v//'`
sum=0
echo "Lastest release is: ${latest}"

tags=`curl -sL https://hub.docker.com/v2/repositories/${image}/tags/ |jq -r .results[].name`

for i in ${tags}
do
  if [ ${i} == ${latest} ];then
    sum=$((sum+1))
  fi
done

if [[ ( $sum -ne 1 ) || ( $1 == "rebuild" ) ]];then
  docker build --no-cache --build-arg VERSION=$latest -t ${image}:${latest} .

  # test
  version=$(docker run -ti --rm ${image}:${latest} version -c )
  #Client: &version.Version{SemVer:"v2.9.0-rc2", GitCommit:"08db2d0181f4ce394513c32ba1aee7ffc6bc3326", GitTreeState:"clean"}
  version=$(echo $version| awk -F \" '{print $2}')
  if [ "${version}" == "v${latest}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  docker tag ${image}:${latest} ${image}:latest

  if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${latest}
    docker push ${image}:latest
  fi

fi
