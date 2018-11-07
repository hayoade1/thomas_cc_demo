#! /bin/bash
cd /tmp

# Stop product service if up already
systemctl stop product.service

# Install hvac:
pip3 install hvac

# Create application directory and create a PID file:
cd /opt
git clone -b hvac https://github.com/kawsark/product-service.git
chown -R ubuntu:ubuntu /opt/product-service
chmod a+x /opt/product-service/product_wrapper.sh
touch /tmp/product-service.pid
chown -R ubuntu:ubuntu /tmp

# Delay to ensure Consul agent is available
sleep 30

# Obtain nonce:
export nonce=$(date +%s%N | md5sum | awk '{print $1}')

# Adjust products.service file with VAULT_TOKEN
cp /lib/systemd/system/product.service /lib/systemd/system/product.service.backup
echo "Environment=AWS_EC2_NONCE=$nonce" >> /lib/systemd/system/product.service
echo "Environment=AWS_EC2_ROLE=dev-role" >> /lib/systemd/system/product.service
echo "Environment=VAULT_SECRET_PATH=mongo/creds/catalog" >> /lib/systemd/system/product.service
echo "ExecStart=/usr/bin/python3 /opt/product-service/product.py" >> /lib/systemd/system/product.service

# Start the service
systemctl daemon-reload
systemctl enable product.service
systemctl start product.service
