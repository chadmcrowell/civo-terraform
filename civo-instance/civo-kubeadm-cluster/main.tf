terraform {
  required_providers {
    civo = {
      source = "civo/civo"
      version = "1.0.41"
    }
  }
}

provider "civo" {
    token = var.civo_api_key
    region = var.region
}

resource "civo_network" "instance_net" {
  label = "instance-net"
}

resource "civo_firewall" "controlplane_firewall" {
  name                 = "controlplane-firewall"
  network_id           = civo_network.instance_net.id
  create_default_rules = false
  ingress_rule {
    label      = "ssh"
    protocol   = "tcp"
    port_range = "22"
    cidr       = [var.local_cidr]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "k8s"
    protocol   = "tcp"
    port_range = "6443"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "etcd"
    protocol   = "tcp"
    port_range = "2379-2380"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "kubelet"
    protocol   = "tcp"
    port_range = "10250-10259"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "http"
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "https"
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  egress_rule {
    label      = "all"
    protocol   = "tcp"
    port_range = "1-65535"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
}

resource "civo_firewall" "workernode_firewall" {
  name                 = "workernode-firewall"
  network_id           = civo_network.instance_net.id
  create_default_rules = false
  ingress_rule {
    label      = "ssh"
    protocol   = "tcp"
    port_range = "22"
    cidr       = [var.local_cidr]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "k8s"
    protocol   = "tcp"
    port_range = "6443"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "nodeport"
    protocol   = "tcp"
    port_range = "30000-32767"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "kubelet"
    protocol   = "tcp"
    port_range = "10250"
    cidr       = [var.local_cidr, "192.168.1.1/32", "192.168.10.4/32", "192.168.10.10/32"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "http"
    protocol   = "tcp"
    port_range = "80"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
  
  ingress_rule {
    label      = "https"
    protocol   = "tcp"
    port_range = "443"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  egress_rule {
    label      = "all"
    protocol   = "tcp"
    port_range = "1-65535"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
}

data "civo_disk_image" "ubuntu" {
   filter {
        key = "name"
        values = ["ubuntu-focal"]
   }
}

resource "civo_instance" "k8s_controlplane" {
    hostname = "k8scontrolplane.xyz"
    disk_image = element(data.civo_disk_image.ubuntu.diskimages, 0).id
    size = "g3.large"
    sshkey_id = "457f9017-e1a8-486a-9bdb-e99486842011"
    firewall_id = civo_firewall.controlplane_firewall.id
    network_id = civo_network.instance_net.id
    
    script = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl gpg
      sudo mkdir -p -m 755 /etc/apt/keyrings
      sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubelet=1.30.1-1.1 kubeadm=1.30.1-1.1 kubectl=1.30.1-1.1
      sudo apt-mark hold kubelet kubeadm kubectl
      sudo apt-get install -y containerd
      sudo mkdir -p /etc/containerd
      containerd config default | sudo tee /etc/containerd/config.toml
      sudo systemctl restart containerd
      sudo sysctl -w net.ipv4.ip_forward=1
      sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf
      sudo sysctl -p
      sudo wget -P $HOME "https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml"
      sudo wget -P $HOME "https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml" 
    EOF
}

resource "civo_instance" "k8s_worker" {
    hostname = "k8sworker.xyz"
    disk_image = element(data.civo_disk_image.ubuntu.diskimages, 0).id
    size = "g3.large"
    sshkey_id = "457f9017-e1a8-486a-9bdb-e99486842011"
    firewall_id = civo_firewall.workernode_firewall.id
    network_id = civo_network.instance_net.id
    
    script = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl gpg
      sudo mkdir -p -m 755 /etc/apt/keyrings
      sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubelet=1.30.1-1.1 kubeadm=1.30.1-1.1 kubectl=1.30.1-1.1
      sudo apt-mark hold kubelet kubeadm kubectl
      sudo apt-get install -y containerd
      sudo mkdir -p /etc/containerd
      containerd config default | sudo tee /etc/containerd/config.toml
      sudo systemctl restart containerd
      sudo sysctl -w net.ipv4.ip_forward=1
      sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf
      sudo sysctl -p
      sudo wget -P $HOME "https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml"
      sudo wget -P $HOME "https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml" 
    EOF
}