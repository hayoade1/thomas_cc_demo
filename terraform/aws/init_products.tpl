#! /bin/bash
cd /tmp

# Adjust products.service file with VAULT_TOKEN
cp /lib/systemd/system/product.service /lib/systemd/system/product.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/product/catalog_token)" >> /lib/systemd/system/product.service

# Start the service
systemctl enable product.service
systemctl start product.service
