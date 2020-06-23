#!/bin/bash

#
# This script will build the base and dev images of mmp and start local containers
#

cd "$(dirname "$0")"

cd ../ #project root

docker build -t mmp_heroku:latest -f Dockerfile.heroku .

