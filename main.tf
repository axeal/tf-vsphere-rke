provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "rke-all" {
  count            = var.count_all_nodes
  name             = "${var.prefix}-rke-all-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.vsphere_cdrom_path
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }

  extra_config = {
    "guestinfo.cloud-init.config.data" = base64encode(templatefile("files/cloud_config", {
      ssh_keys = var.ssh_keys,
      hostname = "${var.prefix}-rke-all-${count.index}"
    }))
    "guestinfo.cloud-init.data.encoding" = "base64"
  }
}

resource "vsphere_virtual_machine" "rke-etcd" {
  count            = var.count_etcd_nodes
  name             = "${var.prefix}-rke-etcd-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.vsphere_cdrom_path
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }

  extra_config = {
    "guestinfo.cloud-init.config.data" = base64encode(templatefile("files/cloud_config", {
      ssh_keys = var.ssh_keys,
      hostname = "${var.prefix}-rke-all-${count.index}"
    }))
    "guestinfo.cloud-init.data.encoding" = "base64"
  }
}

resource "vsphere_virtual_machine" "rke-controlplane" {
  count            = var.count_controlplane_nodes
  name             = "${var.prefix}-rke-controlplane-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.vsphere_cdrom_path
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }

  extra_config = {
    "guestinfo.cloud-init.config.data" = base64encode(templatefile("files/cloud_config", {
      ssh_keys = var.ssh_keys,
      hostname = "${var.prefix}-rke-all-${count.index}"
    }))
    "guestinfo.cloud-init.data.encoding" = "base64"
  }
}

resource "vsphere_virtual_machine" "rke-worker" {
  count            = var.count_worker_nodes
  name             = "${var.prefix}-rke-worker-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.vsphere_cdrom_path
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }

  extra_config = {
    "guestinfo.cloud-init.config.data" = base64encode(templatefile("files/cloud_config", {
      ssh_keys = var.ssh_keys,
      hostname = "${var.prefix}-rke-all-${count.index}"
    }))
    "guestinfo.cloud-init.data.encoding" = "base64"
  }
}

data "template_file" "all_nodes" {
  template = file("files/node.yml.tmpl")
  count    = var.count_all_nodes
  vars = {
    public_ip = vsphere_virtual_machine.rke-all[count.index].default_ip_address
    roles     = "[controlplane,worker,etcd]"
  }
}

data "template_file" "etcd_nodes" {
  template = file("files/node.yml.tmpl")
  count    = var.count_etcd_nodes
  vars = {
    public_ip = vsphere_virtual_machine.rke-etcd[count.index].default_ip_address
    roles     = "[etcd]"
  }
}

data "template_file" "controlplane_nodes" {
  template = file("files/node.yml.tmpl")
  count    = var.count_controlplane_nodes
  vars = {
    public_ip = vsphere_virtual_machine.rke-controlplane[count.index].default_ip_address
    roles     = "[controlplane]"
  }
}

data "template_file" "worker_nodes" {
  template = file("files/node.yml.tmpl")
  count    = var.count_worker_nodes
  vars = {
    public_ip = vsphere_virtual_machine.rke-worker[count.index].default_ip_address
    roles     = "[worker]"
  }
}

data "template_file" "nodes" {
  template = file("files/nodes.yml.tmpl")
  vars = {
    nodes = chomp(
      join(
        "",
        [
          join("", data.template_file.all_nodes.*.rendered),
          join("", data.template_file.etcd_nodes.*.rendered),
          join("", data.template_file.controlplane_nodes.*.rendered),
          join("", data.template_file.worker_nodes.*.rendered),
        ],
      ),
    )
  }
}

resource "local_file" "rke-config" {
  content  = data.template_file.nodes.rendered
  filename = "${path.module}/cluster.yml"
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/files/ssh_config.tmpl", {
    prefix           = var.prefix
    rke-all          = [for node in vsphere_virtual_machine.rke-all : node.default_ip_address],
    rke-etcd         = [for node in vsphere_virtual_machine.rke-etcd : node.default_ip_address],
    rke-controlplane = [for node in vsphere_virtual_machine.rke-controlplane : node.default_ip_address],
    rke-worker       = [for node in vsphere_virtual_machine.rke-worker : node.default_ip_address],
  })
  filename = "${path.module}/ssh_config"
}
