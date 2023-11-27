# Generate a random vm name
resource random_string main {
  length  = 8
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource tls_private_key vm_ssh_keys {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#####################################################################
# Write private SSH key to local file [ssh/${var.ssh_key_name}.pem]
#####################################################################
resource local_sensitive_file vm-ssh-private-key {
  depends_on      = [tls_private_key.vm_ssh_keys]
  filename        = "${path.module}/ssh/${local.hostname}.pem"
  file_permission = 0400
  content         = tls_private_key.vm_ssh_keys.private_key_pem
}

resource proxmox_vm_qemu linux_server {
  depends_on = [
    tls_private_key.vm_ssh_keys
  ]
  # count = 0 will destory all provisioned VMs | count = 3 provisions 3 Linux Ubuntu 23.04 VMs.
  count       = 0
  name        = "${var.basename}-${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name
  full_clone  = "true"
  agent       = 1
  os_type     = "cloud-init"
  cloudinit_cdrom_storage = "local-lvm"
  vmid        = "${var.vmid}${count.index + 1}"
  bios        = "seabios"
  onboot      = "true"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 8192
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"
  disk {
    slot      = 0
    size      = "32G"
    type      = "scsi"
    storage   = "fast0-pve6"
    backup    = true
    iothread  = 1
    discard   = "on"
    cache     = "unsafe"
    ssd       = 1
    aio       = "io_uring"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ssh_user = var.username
  provisioner "remote-exec" {
    script = ./bootstrap_vm.sh" 

    connection {
      type = "ssh"
      host = self.ssh_host
      user = self.ssh_user
      private_key = file(var.private_key_path)
    }
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
