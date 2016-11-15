#!/bin/bash

set -eo pipefail

# use buildkite commit hash as a TAG
TAG=${BUILDKITE_COMMIT::8}

# image name
IMAGE=deisdash

cd /tmp

# clone repo
git clone ${BUILDKITE_REPO}

# cd to pulled repo folder
cd ${BUILDKITE_PIPELINE_SLUG}

# checkout branch
git checkout ${BUILDKITE_BRANCH}

# build docker image
echo -e "\n--- Building :docker: image ${IMAGE}:${TAG}"
docker build -t ${IMAGE}:${TAG} .

# Cleaning up git repo folder
echo "--- Cleaning up git repo folder ${BUILDKITE_PIPELINE_SLUG}"
rm -rf /tmp/${BUILDKITE_PIPELINE_SLUG}

# set ECR docker repository
if [[ "${BUILDKITE_BRANCH}" = "master" ]]
then
  DOCKER_REPO=997652729005.dkr.ecr.us-west-1.amazonaws.com
else
  DOCKER_REPO=997652729005.dkr.ecr.us-west-2.amazonaws.com
fi

# download docker-credential-ecr-login
echo "--- Downloading docker-credential-ecr-login binary"
curl https://s3-us-west-1.amazonaws.com/apihub-coreos/buildkite/docker-credential-ecr-login > /usr/local/bin/docker-credential-ecr-login
chmod +x /usr/local/bin/docker-credential-ecr-login

# tag docker image
docker tag ${IMAGE}:${TAG} ${DOCKER_REPO}/${IMAGE}:${TAG}

# push to ECR
echo "--- Pushing :docker: image ${DOCKER_REPO}/${IMAGE}:${TAG} to ECR"
docker push ${DOCKER_REPO}/${IMAGE}:${TAG}

# clean up built docker image
echo "--- Cleaning up :docker: image ${DOCKER_REPO}/${IMAGE}:${TAG}"
docker rmi -f ${DOCKER_REPO}/${IMAGE}:${TAG}
