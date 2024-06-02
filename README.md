# civo-terraform

This repos is intended for any individual to clone down, add their terraform.tfvars and run quickly and easily.

Contributions welcome! 

- [Civo Instance](./civo-instance/)
- [Civo Kubeadm Cluster with Instances](./civo-instance/civo-kubeadm-cluster/)
- [Civo Managed K8s - K3s with Flannel CNI]
- [Civo Managed K8s - K3s with Cilium]
- [Civo Managed K8s - Talos with Flannel]

## Example Tfvars
copy and paste into your local directory ([.gitignore](./.gitignore) will not check this into version control)

```hcl
civo_api_key = "qtgeTTBLOLK4N7q4mNbK4PEss1HBKCkQkMAgklitRr6n87edQU"

local_cidr = "3.44.213.19"

# find your ssh key id with 'civo sshkey ls'
ssh_key_id = "555g6999-g1g2-499a-9llb-e88486843022"
```