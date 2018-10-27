#! /bin/bash

export VAULT_VERSION="0.11.4"

# Setup pre-requisites
apt-get update
apt-get install -y git unzip curl jq dnsutils wget

# Add Vault user and vault.d directory:
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /etc/vault.d
chown --recursive vault:vault /etc/vault.d
cp /tmp/vault.hcl /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

# Install Vault
curl -v https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
chown root:root vault
mv vault /usr/local/bin/vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
vault --version
