# This script creates an Azure Arc resource to connect a Kubernetes cluster to Azure
# Documentation: https://aka.ms/AzureArcK8sDocs

# Log into Azure
az login --use-device-code

# Set Azure subscription
az account set --subscription "b641e8f9-640c-4efe-9e3e-b8a9a00d7a2d"

az provider register --namespace Microsoft.ExtendedLocation
az provider show -n Microsoft.ExtendedLocation | jq .registrationState

# Create connected cluster
az connectedk8s connect --name "K3S_Cluster_0" --resource-group "sec_telem_law_1" --location "eastus" --correlation-id "c18ab9d0-685e-48e7-ab55-12588447b0ed" --tags "K3S_Cluster_@Home"

# ----------------------------------- K3S Cluster Successfully Onboarded on Azure Arc ---------------------------------------
# Create a JWT token so the K3S cluster is visable from Azure Arc
kubectl create serviceaccount demo-user -n default

kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')

# Copy / Paste the token into the box within Azure Arc
echo $TOKEN
