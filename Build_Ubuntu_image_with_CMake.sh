docker login -u $DockerUser -p $DockerPass
docker build -t $DockerUser/ubuntu-cpp -f ./docker/Dockerfile.ubuntu-cpp .
docker push $DockerUser/ubuntu-cpp
docker rmi $DockerUser/ubuntu-cpp