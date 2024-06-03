resource "civo_network" "cluster_net" {
  label = "cluster-net"
  cidr_v4 = "10.1.0.0/24"
}

resource "civo_firewall" "k8s_firewall" {
  name                 = "k8s-firewall"
  network_id           = civo_network.cluster_net.id
  create_default_rules = false
  ingress_rule {
    label      = "k8s"
    protocol   = "tcp"
    port_range = "6443"
    cidr       = [var.local_cidr, "10.168.1.1/32", "10.168.10.4/32", "10.168.10.10/32"]
    action     = "allow"
  }

  ingress_rule {
    label      = "ssh"
    protocol   = "tcp"
    port_range = "22"
    cidr       = [var.local_cidr, "10.168.1.1/32", "10.168.10.4/32", "10.168.10.10/32"]
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

resource "civo_kubernetes_cluster" "k8s-cluster" {
    name = "k8s-cluster"
    applications = "traefik2-loadbalancer"
    firewall_id = civo_firewall.k8s_firewall.id
    network_id = civo_network.cluster_net.id
    region = var.region
    cluster_type = "k3s" # valid options are 'k3s' or 'talos'
    cni = "flannel" # valid options are 'cilium' or 'flannel'
    kubernetes_version = "1.29.2-k3s1" # list k8s versions with 'civo kubernetes versions'
    pools {
        label = "front-end" // Optional
        size = "g4s.kube.large" # list sizes with 'civo kubernetes size'
        node_count = 3
    }
}