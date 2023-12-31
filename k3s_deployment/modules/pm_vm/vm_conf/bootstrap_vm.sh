#!/bin/bash

USERNAME="$1"

# Get the version of Ubuntu so we can use $VERSION_ID
source /etc/os-release

touch /home/$USERNAME/.hushlogin
sudo chown $USERNAME:$USERNAME /home/$USERNAME/.hushlogin

# Update and upgrade all packages without receiving any prompts
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf

sudo apt update > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1
sudo apt install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common \
gnupg \
net-tools \
wget \
gcc \
g++ \
rustc \
btop \
neofetch \
gdu \
nnn \
openjdk-11-jdk-headless \
python3-dev \
sshpass \
python3-pip > /dev/null 2>&1

# Install Docker && Docker-Compose
curl -sSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sudo bash
sudo usermod -aG docker $USERNAME
curl -sSL https://raw.githubusercontent.com/dcodev1702/install_docker/main/install_docker-compose.sh | sudo bash


###################################
# Install PowerShell and Azure Modules
sudo snap install powershell --classic > /dev/null 2>&1
sudo pwsh -c Install-Module -Name Az -Scope AllUsers -Force > /dev/null 2>&1
sudo pwsh -c Install-Module -Name Az.ConnectedMachine -Scope AllUsers -Force > /dev/null 2>&1

# Install Terraform
sudo snap install terraform --classic > /dev/null 2>&1

# Install Azure CLI
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null 2>&1
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $VERSION_CODENAME main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update > /dev/null 2>&1 && sudo apt-get install -y azure-cli  > /dev/null 2>&1

# Install Azure Bicep
sudo -H -u $USERNAME az bicep install

# Install the latest ansible for K3S provisioning if we're on Ubuntu 20.04, 22.04, or 23.04
if [[ "$VERSION_ID" == "22.04" || "$VERSION_ID" == "20.04" ]]; then
    echo -e "You're running $PRETTY_NAME so we install the latest ansible via pip!"
    sudo -H -u "$USERNAME" python3 -m pip install --upgrade pip
    sudo -H -u "$USERNAME" python3 -m pip install --user ansible

    echo "export ANSIBLE_HOME=/home/$USERNAME/.local/" >> "/home/$USERNAME/.bashrc"
    echo "export PATH=$ANSIBLE_HOME/bin:$PATH" >> "/home/$USERNAME/.bashrc"
elif [[ "$VERSION_ID" == "23.04" ]]; then
    echo -e "You're running $PRETTY_NAME; installing the latest ansible via apt-get!"
    sudo apt install -y ansible > /dev/null 2>&1
fi

# Setup JAVA_HOME ENV for user $USERNAME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/' >> "/home/$USERNAME/.bashrc"
echo "export PATH=$JAVA_HOME/bin:$PATH" >> "/home/$USERNAME/.bashrc"

sleep 2
sudo logger "Initialization installation script (bootstrap_vm.sh) completed successfully."

sleep 2
sudo reboot
