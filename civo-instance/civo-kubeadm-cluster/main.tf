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
}

resource "civo_instance" "k8s_worker" {
    hostname = "k8sworker.xyz"
    disk_image = element(data.civo_disk_image.ubuntu.diskimages, 0).id
    size = "g3.large"
    sshkey_id = "457f9017-e1a8-486a-9bdb-e99486842011"
    firewall_id = civo_firewall.workernode_firewall.id
    network_id = civo_network.instance_net.id
}