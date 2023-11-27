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

VMID=8200
PVE_DISK="fast0-pve6"
DISK_SZ=32
CLOUD_IMG="lunar-server-cloudimg-amd64-disk-kvm.qcow2"
PVE_NODE="pve-6"
PVE_NODE_IP="192.168.10.173:8006"
API_SECRET="ee0d225f-10b7-4d23-9ee9-e3157c37bfc3"

#curl --silent --insecure -H "Authorization: PVEAPIToken=tf@pve!terraform=$API_SECRET" https://$PVE_NODE_IP/api4/json
VM_EXISTS=`curl --silent --insecure -H "Authorization: PVEAPIToken=tf@pve!terraform=$API_SECRET" https://$PVE_NODE_IP/api2/json/nodes/pve-6/qemu/$VMID/status/current | jq .data.name`

# Check if VM exists by VMID using proxmox API, if not, create VM. 
qm create $VMID -name ubun-2304-tmpl-01 -memory 2048 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 -scsihw virtio-scsi-single -cpu cputype="host,flags=-pcid;-spec-ctrl;-ssbd;+pdpe1gb" -description "Ubuntu 23.04 Cloud Image" -agent 1 -serial0 socket -vga serial0
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

# Setup Cloud Init Drive
qm set $VMID --ide2 local-lvm:cloudinit
 
# Ensure THE CLOUD INIT DRIVE is added to IDE02 OR ELSE TF WILL FAIL TO PROVISION THE VM!
# Go to CLOUD INIT and configure the drive
  # Username
  # Password
  # SSH Keys
  # IP CONFIG

# BE SURE TO 'REGENERATE' THE CLOUD INIT DRIVE before converting the VM to a TEMPLATE!!!
