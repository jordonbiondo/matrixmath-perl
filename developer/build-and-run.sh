#!/bin/bash

#
# This script will build the base and dev images of mmp and start local containers
#

cd "$(dirname "$0")"

cd ../ #project root

docker build -t mmp_base:latest -f Dockerfile.mmp_base . &&
    docker build -t mmp_dev:latest -f Dockerfile.mmp_dev . &&
    cd developer &&
    docker-compose down &&
    docker-compose up -d

