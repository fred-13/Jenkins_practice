# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.box = "generic/ubuntu2004"

    config.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 4
    end

    config.vm.define "jenkins" do |testvm|
      testvm.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
      testvm.vm.network "forwarded_port", guest: 8080, host: 8080
      testvm.vm.network "forwarded_port", guest: 50000, host: 50000
      testvm.vm.hostname = "jenkins"
      testvm.vm.provision "file", source: "./Docker", destination: "$HOME/Docker"
      testvm.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get install ca-certificates curl gnupg lsb-release -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
        sudo docker network create jenkins
        sudo docker build -t fred13/jenkins -f ./Docker/Jenkins/Dockerfile.jenkins .
        sudo chmod +x ./Docker/Jenkins/*.sh
        sudo ./Docker/Jenkins/docker_socket_run.sh
        sudo ./Docker/Jenkins/jenkins_server_run.sh
      SHELL
    end

end
