#!/bin/bash

set -e # Make errors fatal

usage() {
  >&2 echo "Usage: $0 base|jupyter|snakemake [--tag-latest]"
  exit 1
}

if (( $# < 1 )); then usage; fi

VER=$(git config -f .gitmodules --get submodule.psi4.branch)

TAG_BASE=nathanpennie/psi4-docker-utils:$1
TAG=$TAG_BASE-$VER
TAG_LATEST=$TAG_BASE-latest
DOCKERFILE=Dockerfile.$1

echo -e "\e[1;37mBuilding \e[0;32m$TAG\e[1;37m using Psi4 version \e[0;32m$VER\e[0m"
echo

if [[ $2 == '--tag-latest' ]]; then
  set -x
  docker build -t $TAG -t $TAG_LATEST --build-arg VER=$VER -f $DOCKERFILE .
else
	if (( $# > 1 )); then usage; fi
	
  set -x
  docker build -t $TAG --build-arg VER=$VER -f $DOCKERFILE .
fi

