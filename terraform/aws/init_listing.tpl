#! /bin/bash
cd /tmp

# Adjust listing.service file with VAULT_TOKEN
cp /lib/systemd/system/listing.service /lib/systemd/system/listing.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/listing/catalog_token)" >> /lib/systemd/system/listing.service

# Start the service
systemctl enable listing.service
systemctl start listing.service
