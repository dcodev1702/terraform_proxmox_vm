#!/bin/bash

# PROXMOX & TERRAFORM NOTES:
# THIS SCRIPT MUST BE RAN ON THE PROXMOX NODE
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

############### ------====|   BEGIN EDITING    |====----- ################
# Ubuntu 22.04 Cloud Image
# URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"

# Ubuntu 23.04 Cloud Image
URL="https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64-disk-kvm.img"

CLOUD_IMG_ORIG=$(basename "$URL")
CLOUD_IMG=$(echo $CLOUD_IMG_ORIG | sed 's/\.img$/.qcow2/')

VMID="9900"
TMPL_NAME="ubun-2304-k3s-tmpl-01"
TMPL_DESCRIPTION="Ubuntu 23.04 Cloud Image for K3S Cluster"
PVE_DISK="fast0-pve6"
DISK_SZ="52"
PVE_NODE="pve-6"
CI_USERNAME="lorenzo"
CI_PASSWORD="password"
############### ------====|     END EDITING     |====----- ################

# Check if VM exists by VMID, if not, create VM.
# Extract VMID from Proxmox Node using awk | Thank you ChatGPT-4
vmids=($(qm list | awk 'NR>1 {print $1}'))

# Check if specified VMID exists on the Proxmox Node
for vmid in "${vmids[@]}"; do
    if [ "$vmid" == "$VMID" ]; then
        echo "Sorry, current VMID:$VMID exists, choose another VMID."
        exit 0
    fi
done

# Create VM
   # VMID
   # Name [ubun-2304-tmpl]
   # OS Type (Linux 2.6 >)
   # SCSI CNTRLR
   # Processors # of cores | Type = HOST and CPU Flags
   # Memory
   # NIC
   # VGA
   
qm create $VMID -name "$TMPL_NAME" -memory 2048 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1 \
                -scsihw virtio-scsi-single -cpu cputype="host,flags=-pcid;-spec-ctrl;-ssbd;+pdpe1gb" \
                -description "$TMPL_DESCRIPTION" -agent 1 -serial0 socket -vga serial0 -ostype l26

# Downloaded and prep the disk 52 GB (size) & install the qemu-guest agent
if [ ! -f "$CLOUD_IMG" ]; then
   wget $URL
   mv $CLOUD_IMG_ORIG $CLOUD_IMG
   qemu-img resize $CLOUD_IMG ${DISK_SZ}G
   virt-customize -a $CLOUD_IMG --install qemu-guest-agent
fi

# Prep the VM and import the cloud image disk (Ubuntu 23.04)
qm importdisk $VMID $CLOUD_IMG $PVE_DISK
qm set $VMID --scsihw virtio-scsi-single --scsi0 "$PVE_DISK:vm-$VMID-disk-0,cache=unsafe,discard=on,iothread=1,ssd=1,aio=io_uring,backup=1"
qm set $VMID --boot c --bootdisk scsi0
 
# Ensure THE CLOUD INIT DRIVE is added to IDE02 OR ELSE TF WILL FAIL TO PROVISION THE VM!
# Configure the cloud-init drive
  # Username
  # Password
  # SSH Keys
  # IP CONFIG

# Setup Cloud Image Drive & Configure in UI
qm set $VMID --ide2 local-lvm:cloudinit

# Configure cloud-init drive
qm set $VMID --ciuser "$CI_USERNAME"
qm set $VMID --cipassword "$CI_PASSWORD"
qm set $VMID --sshkeys ./id_sshkeys.pub
qm set $VMID --ipconfig0 ip=dhcp

# Convert to Template! -- DUN.
qm template $VMID

sleep 5
echo -e "Proxmox VM template completed successfully and is now ready to provision VM's via Terraform!"
