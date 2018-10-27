#! /bin/bash

# Setup userid and password for Vault
export mongo_admin_user="vault-admin"
export mongo_admin_pass=$(date | base64)
cat <<EOF > admin.js
use admin
db.dropUser("${mongo_admin_user}")
db.createUser({ user: "${mongo_admin_user}", pwd: "${mongo_admin_pass}", roles: [{ role: "userAdminAnyDatabase", db: "admin" }] })
EOF
mongo < admin.js

# Store password in consul:
sleep 5
consul kv put config/mongo/mongo_admin_user ${mongo_admin_user}
consul kv put config/mongo/mongo_admin_pass ${mongo_admin_pass}

# Restart mongodb with Authorization
cp /etc/mongod.conf /etc/mongod.conf.backup
echo "security:
    authorization: enabled" >> /etc/mongod.conf
systemctl restart mongod
