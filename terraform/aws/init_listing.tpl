#! /bin/bash
cd /tmp

# Stop listing service if up already
systemctl stop listing.service

# Download updated code and install Vault library:
cd /home/ubuntu/src
rm -rf listing-service
git clone https://github.com/kawsark/listing-service.git
cd listing-service
npm install
npm install node-vault
touch /tmp/listing_wrapper.pid
chown -R ubuntu:ubuntu .
chown -R ubuntu:ubuntu /tmp

# Adjust listing.service file with VAULT_TOKEN
cp /lib/systemd/system/listing.service /lib/systemd/system/listing.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/listing/catalog_token)" >> /lib/systemd/system/listing.service

# Start the service
systemctl daemon-reload
systemctl enable listing.service
systemctl start listing.service

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
