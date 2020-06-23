#!/bin/bash

#
# This script will build the base and dev images of mmp and start local containers
#

cd "$(dirname "$0")"

cd ../ #project root

docker build -t mmp_heroku:latest -f Dockerfile.heroku . &&
    docker tag $(docker images -q mmp_heroku:latest) registry.heroku.com/matrix-math-perl/web &&
    docker push registry.heroku.com/matrix-math-perl/web &&
    heroku container:release web --app matrix-math-perl

