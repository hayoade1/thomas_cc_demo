#! /bin/bash
cd /tmp

# Stop listing service if up already
systemctl stop listing.service

# Create application directory and create a PID file:
cd /opt
git clone https://github.com/kawsark/listing-service.git
cd listing-service
npm install
npm install node-vault
chown -R ubuntu:ubuntu /opt/listing-service
touch /tmp/listing-service.pid
chown -R ubuntu:ubuntu /tmp

# Adjust listing.service file with VAULT_TOKEN
cp /lib/systemd/system/listing.service /lib/systemd/system/listing.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/listing/catalog_token)" >> /lib/systemd/system/listing.service

# Start the service
systemctl daemon-reload
systemctl enable listing.service
systemctl start listing.service
