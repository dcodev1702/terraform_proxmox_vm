#!/bin/bash

# PROXMOS & TERRAFORM NOTES:
#---------------------------
# Follow instructions as already laid out in evernote for cloud image - proxmox

# Use latest proxmox provider
#  -- WHEN CREATING A CLOUD INIT DRIVE, YOU MUST SET CLOUD INIT DRIVE TO IDE02!!!!!
#     IF YOU DO NOT, PROVISIONING VMs WILL SHIT THE BED EVERY TIME! THE PROVIDER IS
#     HARD CODED TO LOOK FOR CLOUD INIT DRIVE ON IDE02!!!
#  -- Use local-lvm as partition to map to cloud init drive
#  -- Cloud image was resized and prepped (KVM Guest Agent installed)
#     REF: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
#
#     On the host used to provison proxmox VMs
#     sudo apt update -y && sudo apt install libguestfs-tools -y
#
#  -- Check to see if VM exists: /api2/json/nodes/{node}/qemu/{vmid}/status/current"
#  -- or
#    Use jq to parse the JSON and extract the value for id 8200
#    result=$(echo "$json" | jq -r --arg vmid "$VMID" '.ids[$vmid]')
#---------------------------
URL="https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64-disk-kvm.img"
CLOUD_IMG_ORIG=$(basename "$URL")

VMID=8900
PVE_DISK="fast0-pve6"
DISK_SZ=32
CLOUD_IMG="lunar-server-cloudimg-amd64-disk-kvm.qcow2"

# Check if VM exists by VMID using proxmox API, if not, create VM. 
# Create VM
   # Set VMID and name [ubun-2304-tmpl]
   # OS
   # REMOVE CDROM
   # REMOVE SCSI CNTRLR
   # Processors # of cores | Type = HOST
   # Memory
   # NIC

# Downloaded and prep the disk 32 GB (size) & by installing qemu guest agent
if [ ! -f "$FILE" ]; then
   wget $URL
   mv $CLOUD_IMG_ORIG $CLOUD_IMG
   qemu-img resize "$CLOUD_IMG ${DISK_SZ}G"
   virt-customize -a $CLOUD_IMG --install qemu-guest-agent
fi

# Prep the VM and import the cloud image disk (Ubuntu 23.04)
qm set $VMID --serial0 socket --vga serial0
qm importdisk $VMID $CLOUD_IMG $PVE_DISK
qm set $VMID --scsihw virtio-scsi-single --scsi0 $PVE_DISK:vm-$VMID-disk-0
qm set $VMID --agent enabled=1
qm set $VMID --boot c --bootdisk scsi0

   # Now go to hardware and add the CLOUD INIT drive. 
   # Ensure THE CLOUD INIT DRIVE is added to IDE02 OR ELSE TF WILL FAIL TO PROVISION THE VM!
   # Go to CLOUD INIT and configure the drive
     # Username
     # Password
     # SSH Keys
     # IP CONFIG
   # BE SURE TO 'REGENERATE' THE CLOUD INIT DRIVE before converting the VM to a TEMPLATE!!!
