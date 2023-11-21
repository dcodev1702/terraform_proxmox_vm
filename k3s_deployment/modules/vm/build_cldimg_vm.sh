#!/bin/bash

# PROXMOS & TERRAFORM NOTES:
#---------------------------
# Follow instructions as already laid out in evernote for cloud image - proxmox

# Use latest proxmox provider
#  -- WHEN CREATING A CLOUD INIT DRIVE, YOU MUST SET CLOUD INIT DRIVE TO IDE02!!!!!
#     IF YOU DO NOT, PROVISIONING WILL SHIT THE BED EVERY TIME!  THE PROVIDER IS
#     LOOKING FOR IDE02!!!
#  -- Use local-lvm as partition to map to cloud init drive
#  -- Cloud image was resized and prepped
#     + <link>
#---------------------------
VMID=8200
PVE_DISK="fast0-pve6"
CLOUD_IMG="ubuntu-23.04-server-cloudimg-amd64-disk-kvm.qcow2"

qm set $VMID --serial0 socket --vga serial0
qm importdisk $VMID $CLOUD_IMG $PVE_DISK
qm set $VMID --scsihw virtio-scsi-single --scsi0 $PVE_DISK:vm-$VMID-disk-0
qm set $VMID --agent enabled=1
qm set $VMID --boot c --bootdisk scsi0
