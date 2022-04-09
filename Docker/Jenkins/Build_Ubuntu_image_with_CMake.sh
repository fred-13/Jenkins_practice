#!/bin/bash

echo "------------------Docker login----------------------"
docker login -u $DockerUser -p $DockerPass

echo "------------------Docker Build image----------------------"
docker pull $DockerUser/ubuntu-cpp:latest
docker build -t $DockerUser/ubuntu-cpp:latest --cache-from $DockerUser/ubuntu-cpp:latest -f ./Docker/Cmake/Dockerfile.ubuntu-cpp .
docker tag $DockerUser/ubuntu-cpp:latest $DockerUser/ubuntu-cpp:version-$BUILD_NUMBER

echo "------------------Docker Push Image----------------------"
docker push $DockerUser/ubuntu-cpp:latest
docker push $DockerUser/ubuntu-cpp:version-$BUILD_NUMBER
docker rmi $DockerUser/ubuntu-cpp:latest
docker rmi $DockerUser/ubuntu-cpp:version-$BUILD_NUMBER