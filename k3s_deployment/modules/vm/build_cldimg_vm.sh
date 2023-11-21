#!/bin/bash

# PROXMOS & TERRAFORM NOTES:
#---------------------------
# Follow instructions as already laid out in evernote for cloud image - proxmox

# Use latest proxmox provider
#  -- WHEN CREATING A CLOUD INIT DRIVE, YOU MUST SET CLOUD INIT DRIVE TO IDE02!!!!!
#     IF YOU DO NOT, PROVISIONING WILL SHIT THE BED EVERY TIME!  THE PROVIDER IS
#     LOOKING FOR IDE02!!!
#  -- Use local-lvm as partition to map to cloud init drive
#  -- Cloud image was resized and prepped (KVM Guest Agent installed)
#     REF: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
#
#     On the host used to provison proxmox VMs
#     sudo apt update -y && sudo apt install libguestfs-tools -y
#---------------------------
VMID=8200
PVE_DISK="fast0-pve6"
DISK_SZ=32
CLOUD_IMG="lunar-server-cloudimg-amd64-disk-kvm.qcow2"

# Create VM
   # Set VMID and name [ubun-2304-tmpl]
   # OS
   # REMOVE CDROM
   # REMOVE SCSI CNTRLR
   # Processors # of cores | Type = HOST
   # Memory
   # NIC

# Downloaded and prep the disk
wget https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64-disk-kvm.img
mv lunar-server-cloudimg-amd64-disk-kvm.img $CLOUD_IMG
qemu-img resize "$CLOUD_IMG ${DISK_SZ}G"
virt-customize -a $CLOUD_IMG --install qemu-guest-agent
virt-customize -a $CLOUD_IMG --run-command 'touch /home/lorenzo/.hushlogin'


# Prep the VM and import the cloud image disk (Ubuntu 23.04)
qm set $VMID --serial0 socket --vga serial0
qm importdisk $VMID $CLOUD_IMG $PVE_DISK
qm set $VMID --scsihw virtio-scsi-single --scsi0 $PVE_DISK:vm-$VMID-disk-0
qm set $VMID --agent enabled=1
qm set $VMID --boot c --bootdisk scsi0
