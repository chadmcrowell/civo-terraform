# Civo Terraform IaC
Creating [Civo](https://dashboard.civo.com/signup) infrastructure in the cloud using the [Civo Terraform Provider](https://registry.terraform.io/providers/civo/civo/latest/docs).

This repos is intended for any individual to clone down, add their terraform.tfvars and run `terraform init && terraform apply` with minimal effort. 

That being said, I would read the below to get info from your Civo account to insert into your local [tfvars](#example-tfvars) file.

Contributions welcome! 

- [Civo Instance - Ubuntu](./civo-instance/civo-ubuntu-instance/)
- [Civo Instance - Rocky](./civo-instance/civo-rocky-instance/)
- [Civo Instance - Debian](./civo-instance/civo-debian-instance/)
- [Kubeadm Cluster with Civo Instances](./civo-instance/civo-kubeadm-cluster/)
- [Civo Managed K8s - K3s with Flannel CNI](./civo-managed-k8s/civo-k3s-flannel/)
- [Civo Managed K8s - K3s with Cilium](./civo-managed-k8s/civo-k3s-cilium/)
- [Civo Managed K8s - Talos with Flannel](./civo-managed-k8s/civo-talos-flannel/)

## Lookup Civo Account - Civo CLI
> PREREQUISITE: [Civo CLI](https://www.civo.com/docs/overview/civo-cli)
```bash
# find your sshkey ('civo sshkey add..' to add a new one)
civo sshkey ls

# find your api key
civo apikey show

# list all regions
civo region ls

# set region (list all regions with 'civo region ls')
civo region current nyc1

# find machine images for civo instance
civo diskimage ls

# find available instance sizes
civo instance size

# find available k8s node sizes
civo kubernetes size

# list available k8s versions
civo kubernetes versions

# list cluster applications to add to your cluster at startup
civo kubernetes applications ls

```

## Example Tfvars
copy and paste into your local directory ([.gitignore](./.gitignore) will not check this into version control)

```hcl
civo_api_key = "qtgeTTBLOLK4N7q4mNbK4PEss1HBKCkQkMAgklitRr6n87edQU"

local_cidr = "3.44.213.19"

# find your ssh key id with 'civo sshkey ls'
ssh_key_id = "555g6999-g1g2-499a-9llb-e88486843022"
```