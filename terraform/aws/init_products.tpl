#! /bin/bash
cd /tmp

# Stop product service if up already
systemctl stop product.service

# Download updated code and Vault library:
pip3 install hvac
cd /home/ubuntu/src
rm -rf product-service
git clone https://github.com/kawsark/product-service.git
touch /tmp/product_wrapper.pid
chown -R ubuntu:ubuntu .
chown -R ubuntu:ubuntu /tmp

# Adjust products.service file with VAULT_TOKEN
cp /lib/systemd/system/product.service /lib/systemd/system/product.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/product/catalog_token)" >> /lib/systemd/system/product.service

# Start the service
systemctl daemon-reload
systemctl enable product.service
systemctl start product.service

# install mongodb for testing
echo "### apt-key adv"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sleep 5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sleep 5
echo "### apt-get update"
sudo apt-get update
sleep 5
sudo apt-get install -y -qq mongodb-org
sleep 5

# Install Vault client for testing
apt-get update -y
apt-get install curl jq -y
curl -v -o vault.zip "https://releases.hashicorp.com/vault/${vault_client_version}/vault_${vault_client_version}_linux_amd64.zip"
unzip vault.zip
chown root:root vault
mv vault /usr/local/bin/vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
vault --version
