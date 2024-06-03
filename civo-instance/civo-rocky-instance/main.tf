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

resource "civo_network" "jumphost_net" {
  label = "rkjumphost-net"
}

resource "civo_firewall" "jump_firewall" {
  name                 = "rkjump-firewall"
  network_id           = civo_network.jumphost_net.id
  create_default_rules = false
  ingress_rule {
    label      = "ssh"
    protocol   = "tcp"
    port_range = "22"
    cidr       = [var.local_cidr]
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
        values = ["ubuntu-focal"] # search for disk images with 'civo diskimage ls'
   }
}

resource "civo_instance" "vm" {
    hostname = "vm.xyz"
    disk_image = element(data.civo_disk_image.ubuntu.diskimages, 0).id
    size = "g3.xlarge" # show all sizes with 'civo instance size"
    sshkey_id = var.ssh_key_id
    
    script = local.startup_script
}

