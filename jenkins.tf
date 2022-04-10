#-------------------G-Core cloud project------------#
data "gcore_project" "pr" {
  name = "a.meshcherakov"
}

data "gcore_region" "rg" {
  name = "Saint Petersburg"
}

data "gcore_image" "ubuntu" {
  name = "ubuntu-20.04"
  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id
}

data "gcore_securitygroup" "default" {
  name = "default"
  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id
}

#---------------Network-----------------#
resource "gcore_network" "network" {
  name = "network_otus"
  mtu = 1450
  type = "vxlan"
  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id
}

#--------------Subnet-----------------#
resource "gcore_subnet" "subnet" {
  name = "subnet_otus"
  cidr = "192.168.10.0/24"
  network_id = gcore_network.network.id
  dns_nameservers = ["8.8.4.4", "1.1.1.1"]

  host_routes {
    destination = "10.0.3.0/24"
    nexthop = "10.0.0.13"
  }

  gateway_ip = "192.168.10.1"
  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id
}

#-----------Fixed IP for Jenkins server-------------#
resource "gcore_reservedfixedip" "fixed_ip_jenkins" {
  project_id = data.gcore_project.pr.id
  region_id = data.gcore_region.rg.id
  type = "ip_address"
  network_id = gcore_network.network.id
  fixed_ip_address = "192.168.10.7"
  is_vip = false
}

#------------External IP for Jenkins server-------------#
resource "gcore_floatingip" "fip_jenkins" {
  project_id = data.gcore_project.pr.id
  region_id = data.gcore_region.rg.id
  fixed_ip_address = gcore_reservedfixedip.fixed_ip_jenkins.fixed_ip_address
  port_id = gcore_reservedfixedip.fixed_ip_jenkins.port_id
}

#-------------Volumes for Jenkins server-----------#
resource "gcore_volume" "jenkins_first_volume" {
  name = "boot volume"
  type_name = "ssd_hiiops"
  size = 40
  image_id = data.gcore_image.ubuntu.id
  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id
}

#-------------Jenkins instance-------------#
resource "gcore_instance" "jenkins_instance" {
  flavor_id = "g0-standard-2-4"
  name = "jenkins"
  keypair_name = "WSL"

  volume {
    source = "existing-volume"
    volume_id = gcore_volume.jenkins_first_volume.id
    boot_index = 0
  }

  interface {
    type = "reserved_fixed_ip"
        port_id = gcore_reservedfixedip.fixed_ip_jenkins.port_id
        fip_source = "existing"
        existing_fip_id = gcore_floatingip.fip_jenkins.id
  }

  security_group {
    id = data.gcore_securitygroup.default.id
    name = "default"
  }

  metadata_map = {
    some_key = "some_value"
    stage = "dev"
  }

  configuration {
    key = "some_key"
    value = "some_data"
  }

  region_id = data.gcore_region.rg.id
  project_id = data.gcore_project.pr.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    host        = gcore_floatingip.fip_jenkins.floating_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "hostname",
      "sudo apt-get update",
      "sudo apt-get install ca-certificates curl gnupg lsb-release -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh -o "StrictHostKeyChecking no" ubuntu@${gcore_floatingip.fip_jenkins.floating_ip_address}
      scp -r ./Docker/Jenkins ubuntu@${gcore_floatingip.fip_jenkins.floating_ip_address}:~
      ansible-playbook -i ${gcore_floatingip.fip_jenkins.floating_ip_address}, ./Ansible/nginx_deploy.yaml -u ubuntu -b
      ansible-playbook -i ${gcore_floatingip.fip_jenkins.floating_ip_address}, ./Ansible/jenkins_deploy.yaml -u ubuntu -b
  EOT
  }

}

output "floating_ip_external_jenkins" {
  description = "External IP"
  value       = gcore_floatingip.fip_jenkins
}