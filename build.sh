#!/bin/bash

set -e

ARGS="${ARGS} $@"

if [ ! -z "${DEPLOY}" ]; then
    ARGS="${ARGS} --push"
fi

if [ "${CI_COMMIT_BRANCH}" == "master" ]; then
    ARGS="${ARGS} --tag ${REPO}/${TARGET}:latest"
fi

# Run Docker build
docker buildx build "." \
--tag ${REPO}/${TARGET}:${TAG} \
--target ${TARGET} \
--platform=${PLATFORM} \
${ARGS}
