# Terraform config to launch nodes for an RKE cluster in vSphere

## Summary

This Terraform setup will:

- Provision vSphere VMs with RancherOS
- Create a cluster.yml configuration file containing those VMs to enable provisioning a Kubernetes clusters with [Rancher Kubernetes Engine (RKE)](https://rancher.com/docs/rke/latest/en/)
- Create an ssh_config file in the terraform module directory for connecting to the VMs

## Other options

All available options/variables are described in [terraform.tfvars.example](https://github.com/axeal/tf-vsphere-rke/blob/master/terraform.tfvars.example).

## How to use

- Clone this repository
- Move the file `terraform.tfvars.example` to `terraform.tfvars` and edit (see inline explanation)
- Run `terraform init`
- Run `terraform apply`
- Once terraform provisioning has completed you can provision a Kubernetes cluster with RKE `rke up --config cluster.yml`. The RKE binary is required and can be [installed per docs](https://rancher.com/docs/rke/latest/en/installation/)
- When `terraform destroy` is performed, the Kubernetes CLI configuration file `kube_config_cluster.yml` and RKE state file `cluster.rkestate` auto-generated by RKE will be deleted from the directory, if present, alongside the `cluster.yml` created by terraform.

## Installing Rancher after provisioning cluster with RKE

### Rancher generated self-signed certificates

- Run `./rancher-install.sh -H <rancher hostname> -v <version string>` where <rancher hostname> is the URL for the rancher server and <version string> is a version string of the format 2.2.8 for example.

### letsEncrypt certificates

- Run `./rancher-install.sh -H <rancher hostname> -v <version string> -t letsEncrypt` where <rancher hostname> is the URL for the rancher server and <version string> is a version string of the format 2.2.8 for example.

### Custom certificates

- Run `./certs.sh <rancher hostname>` where <rancher hostname> is the URL for the rancher server for which to generate certificates.
- Run `./rancher-install.sh -H <rancher hostname> -v <version string> -t secret` where <rancher hostname> is the URL for the rancher server and <version string> is a version string of the format 2.2.8 for example.

## SSH Config

You can use the use the auto-generated ssh_config file to connect to the VMs by VM name, e.g. `ssh <prefix>-rke-0-all` or `ssh <prefix>-rke-1-etcd` etc. To do so, you have two options:

1. Add an `Include` directive at the top of the SSH config file in your home directory (`~/.ssh/config`) to include the ssh_config file at the location you have checked out the this repository, e.g. `Include ~/git/tf-do-rke/ssh_config`.

2. Specify the ssh_config file when invoking `ssh` via the `-F` option, e.g. `ssh -F ~/git/tf-do-rke/ssh_config <host>`.
