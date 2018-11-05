#! /bin/bash
cd /tmp

# Stop product service if up already
systemctl stop product.service

# Create application directory and create a PID file:
cd /opt
git clone https://github.com/kawsark/product-service.git
chown -R ubuntu:ubuntu /opt/product-service
chmod a+x /opt/product-service/product_wrapper.sh
touch /tmp/product-service.pid
chown -R ubuntu:ubuntu /tmp

# Delay to ensure Consul agent is available
sleep 30

# Adjust products.service file with VAULT_TOKEN
cp /lib/systemd/system/product.service /lib/systemd/system/product.service.backup
echo "Environment=VAULT_TOKEN=$(consul kv get config/product/catalog_token)" >> /lib/systemd/system/product.service

# Start the service
systemctl daemon-reload
systemctl enable product.service
systemctl start product.service
