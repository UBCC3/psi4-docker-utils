#!/bin/bash

set -e # Make errors fatal

usage() {
  >&2 echo "Usage: $0 base|jupyter|snakemake [--tag-latest] [--push]"
  exit 1
}

if (( $# < 1 )); then usage; fi

VER=$(git config -f .gitmodules --get submodule.psi4.branch)

TAG_BASE=ubchemica/psi4-docker-utils:$1
TAG=$TAG_BASE-$VER
TAG_LATEST=$TAG_BASE-latest
DOCKERFILE=Dockerfile.$1

DO_TAG_LATEST=false
DO_PUSH=false
if [[ $2 == '--tag-latest' ]] || [[ $3 == '--tag-latest' ]]; then DO_TAG_LATEST=true; fi
if [[ $2 == '--push' ]] || [[ $3 == '--push' ]]; then DO_PUSH=true; fi

echo -e "\e[1;37mBuilding \e[0;32m$TAG\e[1;37m using Psi4 version \e[0;32m$VER\e[0m"
if [ $DO_PUSH = true ]; then
  echo -e "\e[1;37mWARNING: \e[0;33mThe image will be pushed to Docker Hub. If this is not what you want, press Ctrl + C now, and rerun without --push\e[0m"
fi
echo

if [ $DO_TAG_LATEST = true ]; then
  set -x
  docker build -t $TAG -t $TAG_LATEST --build-arg VER=$VER -f $DOCKERFILE .
else
	if (( $# > 1 )); then usage; fi
	
  set -x
  docker build -t $TAG --build-arg VER=$VER -f $DOCKERFILE .
fi

if [ $DO_PUSH = true ]; then
  docker push $TAG
  if [ $DO_TAG_LATEST = true ]; then
    docker push $TAG_LATEST
  fi
fi
