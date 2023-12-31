# Proxmox : Terraform : K3S

## Assumptions
* You have a Proxmox Server/Cluster capable of running 4+ Linux VM's
* You have an Internet Connection
* You're comfortable with the CLI in Linux
* Understand containerization concepts
* Watch lots of home lab YouTube content :)
    
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

```console
ssh root@pve-6
```
```console
apt update -y && apt install libguestfs-tools -y
```
```console
cd k3s_deployment/modules/pm_vm_template
```
* Add SSH public keys to the id_sshkeys.pub file as this file is used to seed the cloud image drive.
* Change variables in [build_cloud_image_vm_template.sh](https://github.com/dcodev1702/terraform_proxmox_vm/blob/main/k3s_deployment/modules/pm_vm_template/build_cloud_image_vm_template.sh) to ensure you're pointing to the right PVE SERVER, PVE DISK, etc. <br />
<br />

![E48EEBCB-EC90-4F72-BDEC-BBF7299F596E](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/fae6b4cc-fd14-490b-b49d-91bc0f4239fb)

```console
bash ./build_vm_template.sh
```

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/2948124e-76bd-4f54-8c78-3459f73d38d4)

VIRTUAL MACHINE TEMPLATE: [9900 - ubun2204-k3s-tmpl-01]
![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/8fd59f13-8970-43e5-83d7-79e0c80ae2ed)


* Provision 5 - 6 VM's from VM template using Terraform
  * 3 Server Nodes and 2 - 3 Worker Nodes
    * Server Nodes: 2 CPU / 4 GB RAM  (2 GB min)
    * Worker Nodes: 2 CPU / 8 GB RAM
  * edit terraform.tfvars and main.tf as required
  * assign static ip scheme to support K3S deployment
<br />

```console
terraform init
```
```console
terraform apply -auto-approve
```

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/d796d06c-e695-45ee-9da6-7032fa4a363d)

<br />

K3S SRVR::VIRTUAL MACHINES: [7701/2/3 - k3s-srvr-nodes-(1-3)] FROM THE TEMPLATE ON PVE-6: [9900 - ubun2204-k3s-tmpl-01]
![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/a8368d38-0dd0-486b-8dc4-f9bdf97c1c30)


K3S WRKR::VIRTUAL MACHINES: [7201/2/3 - k3s-wrkr-nodes-(1-3)] FROM THE TEMPLATE ON PVE-5: [9200 - ubun2204-k3s-tmpl-02]
![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/35a56f05-ad66-436f-ae65-9e9e737cdbac)

<br />

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/8dbf61c8-4622-442b-b2d5-81d328964d42)

* Execute K3S deployment script
```console
./k3s.sh
```
  * Jim's Garage TY Channel: https://www.youtube.com/watch?v=6k8BABDXeZI
  * Go to: http://LOADBALANCER_IP and the Nginx page should appear
    * http://192.168.10.52

ENJOY and begin to containerize all the things! <br />
Major Shout Out to all of the YouTube Home Lab content creators that helped me create this solution! <br />

![image](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/6c45d71b-9edb-4ef7-a3e1-cf5770c0f99f)

## Set up Rancher (Branch: Alpha)
* [Install Helm](https://helm.sh/docs/intro/install/)
* [Setup Rancher](https://ranchermanager.docs.rancher.com/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster)
```console
helm repo add rancher-alpha https://releases.rancher.com/server-charts/alpha
```
```console
kubectl create namespace cattle-system
```
```console
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
```
```console
helm repo add jetstack https://charts.jetstack.io
```
```console
helm repo update
```
```console
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace --version v1.11.0
```
```console
kubectl get pods --namespace cert-manager
```
```console
helm install rancher rancher-alpha/rancher --devel \
  --namespace cattle-system \
  --set hostname=rancher.cloudhunters.io \
  --set bootstrapPassword=admin
```
```console
kubectl -n cattle-system rollout status deploy/rancher
```
```console
kubectl -n cattle-system get deploy rancher
```
```console
kubectl expose deployment rancher --name rancher-lb --port=443 --type=LoadBalancer -n cattle-system service/rancher-lb exposed
```

* Rancher - K3S GUI Management Console

![349B9361-75BD-4F5F-B473-5943E35DD2F5](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/5a395e8e-c85b-45f8-9185-85f606b76b55)

![08E62692-E6E4-4CB0-A289-19C5BA697C92](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/add56d1c-b21f-4f1b-b24a-fb44e21fc09e)

![449034E0-3672-4194-A3B1-6B047A892347](https://github.com/dcodev1702/terraform_proxmox_vm/assets/32214072/257999e0-992a-4dc2-9f52-cc5c4aa4fc84)



