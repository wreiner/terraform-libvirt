terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

# # ---- VARIABLES ----

variable "libvirt-uri" {
  description = "Complete URI of target libvirt system"
  type = string
  default = "qemu:///system"
}

variable "vm-name" {
  description = "Name of the new vm instance"
  type = string
}

variable "vm-size" {
  description = "Size of the new vm instance"
  type = number
  default = 10737418240
}

variable "vm-memory" {
  description = "RAM size of the new vm instance"
  type = number
  default = 1024
}

variable "vm-vcpu" {
  description = "vCPU count of the new vm instance"
  type        = number
  default     = 1
}

variable "pool" {
  description = "Name of the pool to deployt the disks to"
  type = string
}

variable "ssh-public-key-file" {
  description = "Public key file for the ansible user"
  type        = string
}

variable "iso_base_dir" {
  description = "Directory which holds all base and ISO images"
  default     = "/var/lib/libvirt/iso_base"
}

variable "base-img" {
  description = "Image which should be used to generate OS image. The image must be located in the iso_base pool"
  type        = string
  default     = "debian-11-generic-amd64.qcow2"
}

variable "vm-network-interfaces" {
  description = "A list of networks for which to create network interfaces"
  type        = list(string)
  default     = ["default"]
}

# ---- PROVIDERS ----

provider "libvirt" {
  uri = "${var.libvirt-uri}"
}

# ---- BASE IMAGES ----

resource "libvirt_volume" "base-image" {
  name   = "${var.vm-name}-base.qcow2"
  pool   = "${var.pool}"
  source = "${var.iso_base_dir}/${var.base-img}"
}

# ---- CLOUD INIT ----

data "template_file" "user_data" {
  template = templatefile(
    "${path.module}/cloud_init.cfg", {
      ssh-public-key-file = var.ssh-public-key-file,
      vm-name = var.vm-name,
      vm-domain = var.vm-domain
    }
  )
}

resource "libvirt_cloudinit_disk" "initdisk" {
  name      = "${var.vm-name}-init.iso"
  user_data = data.template_file.user_data.rendered
  pool      = "${var.pool}"
}


# ---- INSTANCES ----

# Volumes

resource "libvirt_volume" "instance" {
  name           = "${var.vm-name}.qcow2"
  pool           = "${var.pool}"
  # source         = "http://192.168.2.32:8000/debian-11-generic-amd64.qcow2"
  base_volume_id = libvirt_volume.base-image.id
  format         = "qcow2"
  size           = var.vm-size
}

# Create the machine
resource "libvirt_domain" "domain-instance" {
  name   = "${var.vm-name}"
  memory = "${var.vm-memory}"
  vcpu   = "${var.vm-vcpu}"

  # cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu_resized.id
  cloudinit = libvirt_cloudinit_disk.initdisk.id

  dynamic "network_interface" {
    for_each = var.vm-network-interfaces
    content {
      network_name = network_interface.value
    }
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.instance.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# -[Output]-------------------------------------------------------------
output "ipv4" {
  value = libvirt_domain.domain-instance
}
