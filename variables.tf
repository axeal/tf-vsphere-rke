variable "prefix" {
}

variable "vsphere_user" {
  default = ""
}

variable "vsphere_password" {
  default = ""
}

variable "vsphere_server" {
  default = ""
}

variable "vsphere_datacenter" {
  default = ""
}

variable "vsphere_datastore" {
  default = ""
}

variable "vsphere_resource_pool" {
  default = ""
}

variable "vsphere_network" {
  default = ""
}

variable "vsphere_cdrom_path" {
  default = ""
}

variable "ssh_keys" {
  default = []
}

variable "cpus" {
  default = 2
}

variable "memory" {
  default = 2048
}

variable "disk_size" {
  default = 20
}

variable "count_all_nodes" {
  default = "1"
}

variable "count_etcd_nodes" {
  default = "0"
}

variable "count_controlplane_nodes" {
  default = "0"
}

variable "count_worker_nodes" {
  default = "0"
}
