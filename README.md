# Civo Terraform IaC
Creating [Civo](https://dashboard.civo.com/signup) infrastructure in the cloud using the [Civo Terraform Provider](https://registry.terraform.io/providers/civo/civo/latest/docs).

This repos is intended for any individual to clone down, add their terraform.tfvars and run `terraform init && terraform apply` with minimal effort. 

That being said, I would read the below to get info from your Civo account to insert into your local [tfvars](#example-tfvars) file.

Contributions welcome! 

- [Civo Instance - Ubuntu](./civo-instance/civo-ubuntu-instance/)
- [Civo Instance - Rocky](./civo-instance/civo-rocky-instance/)
- [Civo Instance - Debian](./civo-instance/civo-debian-instance/)
- [Kubeadm Cluster with Civo Instances](./civo-instance/civo-kubeadm-cluster/)
- [Civo Managed K8s - K3s with Flannel CNI]
- [Civo Managed K8s - K3s with Cilium]
- [Civo Managed K8s - Talos with Flannel]

## Lookup Civo Account - Civo CLI

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
```

## Example Tfvars
copy and paste into your local directory ([.gitignore](./.gitignore) will not check this into version control)

```hcl
civo_api_key = "qtgeTTBLOLK4N7q4mNbK4PEss1HBKCkQkMAgklitRr6n87edQU"

local_cidr = "3.44.213.19"

# find your ssh key id with 'civo sshkey ls'
ssh_key_id = "555g6999-g1g2-499a-9llb-e88486843022"
```