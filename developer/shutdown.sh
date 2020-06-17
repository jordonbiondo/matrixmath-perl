#!/bin/bash

#
# This script will shut down the local development docker containers
#

cd "$(dirname "$0")"

docker-compose down
