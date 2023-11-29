# Proxmox : Terraform : K3S

## Order of operations
* Create Proxmox User w/ API Token
* Create VM template via 'build_cloud_image_vm_template.sh' (must be done on proxmox host)
  * edit script to fit your proxmox environment
  * assign ssh public key in build script for cloud init drive
  * Currently designed to create Ubuntu 23.04 Cloud Image VM/Template
* Provision 5 - 6 VM's from VM template using Terraform
  * 3 Server Nodes and 2 - 3 Worker Nodes
  * edit terraform.tfvars and main.tf as required
  * assign static ip scheme to support K3S deployment
* Execute K3S deployment script
  * go to: http://LOADBALANCER_IP and the Nginx page should appear

ENJOY and begin to containerize all the things! <br />
Major Shout Out to all of the YouTube Home Lab content creators that helped me create this solution! <br />
