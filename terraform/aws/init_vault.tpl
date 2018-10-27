#! /bin/bash

chown -R ubuntu /tmp
cd /tmp

# Delay Vault start to allow mongod to come up:
sleep 60
systemctl start vault

# Delay vault initialization
sleep 20

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /tmp/vault.txt
cat /tmp/vault.txt | jq -r '.unseal_keys_b64[0]' > /tmp/unseal_key
cat /tmp/vault.txt | jq -r .root_token > /tmp/root_token
export VAULT_TOKEN=$(cat /tmp/root_token)

sleep 20
vault operator unseal $(cat /tmp/unseal_key)

# Setup Vault access for ubuntu user:
echo "export VAULT_ADDR=\"http://vault.service.consul:8200\"" >> /home/ubuntu/.bashrc
echo "export VAULT_TOKEN=$(cat /tmp/root_token)" >> /home/ubuntu/.bashrc
chown ubuntu /tmp/vault.txt
chown ubuntu /tmp/root_token
chown ubuntu /tmp/unseal_key

# Setup MongoDB database secrets engine
sleep 10
vault secrets enable -path mongo database

vault write mongo/config/ec2-dev-mongo \
    plugin_name=mongodb-database-plugin \
    allowed_roles="catalog" \
    connection_url="mongodb://{{username}}:{{password}}@${mongo_server_ip}:27017/admin?ssl=false" \
    username="$(consul kv get config/mongo/mongo_admin_user)" \
    password="$(consul kv get config/mongo/mongo_admin_pass)"

# Import the Catalog policy
cat <<EOF > /tmp/catalog.policy
path "mongo/creds/catalog" {
  capabilities = ["read"]
}
EOF

vault policy write catalog /tmp/catalog.policy
vault token create -policy=catalog -format=json | tee >(jq -r .auth.client_token > /tmp/catalog_token)
consul kv put config/product/catalog_token $(cat /tmp/catalog_token)

vault write mongo/roles/catalog \
    db_name=ec2-dev-mongo \
    creation_statements='{ "db": "admin", "roles": [{"role": "read", "db": "bbthe90s"}] }' \
    default_ttl="1m" \
    max_ttl="2m"

# Test

## install mongodb
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

## Test mongo using new credentials:
export VAULT_TOKEN=$(cat /tmp/catalog_token)
vault token lookup
vault read -format=json mongo/creds/catalog > /tmp/catalogtest.txt
cat /tmp/catalogtest.txt | jq -r .data.password > /tmp/catalog_pass
cat /tmp/catalogtest.txt | jq -r .data.username > /tmp/catalog_user

cat <<EOF > /tmp/mongo-test.js
use bbth90s
show collections
db.products.find()
db.listings.find()
EOF
mongo --port 27017 --host mongodb.service.consul -u "$(cat /tmp/catalog_user)" -p "$(cat /tmp/catalog_pass)" --authenticationDatabase "admin"  < /tmp/mongo-test.js
