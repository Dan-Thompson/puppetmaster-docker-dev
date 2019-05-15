#!/bin/bash

docker build -t slave -f Dockerfile.slave . 
docker build -t puppet .
