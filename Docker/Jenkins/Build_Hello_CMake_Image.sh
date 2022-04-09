#!/bin/bash

echo "------------------Docker login----------------------"
docker login -u $DockerUser -p $DockerPass

echo "------------------Docker Build image----------------------"
docker pull $DockerUser/hello-cmake:latest
docker build -t $DockerUser/hello-cmake:latest --cache-from $DockerUser/hello-cmake:latest -f ./Docker/Cmake/Dockerfile.hello-cmake .
docker tag $DockerUser/hello-cmake:latest $DockerUser/hello-cmake:version-$BUILD_NUMBER

echo "------------------Docker Push Image----------------------"
docker push $DockerUser/hello-cmake:latest
docker push $DockerUser/hello-cmake:version-$BUILD_NUMBER

echo "----------Run docker container 'hello-cmake'----------"
docker run $DockerUser/hello-cmake:version-$BUILD_NUMBER

docker rmi $DockerUser/hello-cmake:latest
docker rmi $DockerUser/hello-cmake:version-$BUILD_NUMBER