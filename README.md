# Proxmox : Terraform : K3S

## Assumptions
* You have a Proxmox Cluster capable of running 6 Linux VM's
* You have an Internet Connection
* You're comfortable with the CLI in Linux.
* Watch lots of home lab YouTube content
    
## Order of operations
* Create Proxmox User w/ API Token
* Create VM template via 'build_cloud_image_vm_template.sh' (must be done on proxmox host)
  * edit script to fit your proxmox environment
    * VMID
    * TMPL_NAME
    * TMPL_DESCRIPTION
    * PVE_DISK
    * DISK_SZ
    * PVE_NODE
  * assign ssh public key in build script for cloud init drive
  * Currently designed to create Ubuntu 23.04 Cloud Image VM/Template
* Provision 5 - 6 VM's from VM template using Terraform
  * 3 Server Nodes and 2 - 3 Worker Nodes
    * Server Nodes: 2 CPU / 4 GB RAM  (2 GB min)
    * Worker Nodes: 2 CPU / 8 GB RAM
  * edit terraform.tfvars and main.tf as required
  * assign static ip scheme to support K3S deployment
<br />

VIRTUAL MACHINE TEMPLATE: [9200 - ubun2204-k3s-tmpl-02]
![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/b116b5aa-cd4a-45f0-9b68-d378f1422a54)

<br />

VIRTUAL MACHINE: [7201 - k3s-wrkr-nodes-1] FROM THE TEMPLATE: [9200 - ubun2204-k3s-tmpl-02]
![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/8cd59c9d-fe3c-4c8d-a811-a43125e786f9)

<br />

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/8dbf61c8-4622-442b-b2d5-81d328964d42)

* Execute K3S deployment script
  * Jim's Garage TY Channel: https://www.youtube.com/watch?v=6k8BABDXeZI
  * Go to: http://LOADBALANCER_IP and the Nginx page should appear
    * http://192.168.10.52

ENJOY and begin to containerize all the things! <br />
Major Shout Out to all of the YouTube Home Lab content creators that helped me create this solution! <br />

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/a20bf08f-70c0-4678-a7b6-f5a68979ce1c)

