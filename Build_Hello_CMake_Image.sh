docker login -u $DockerUser -p $DockerPass
docker build -t $DockerUser/hello-cmake -f ./docker/Dockerfile.hello-cmake .
docker push $DockerUser/hello-cmake
echo "----------Run docker container 'hello-cmake'----------"
docker run $DockerUser/hello-cmake
docker rmi $DockerUser/ubuntu-cpp