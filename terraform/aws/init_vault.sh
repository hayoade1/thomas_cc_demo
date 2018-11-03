#! /bin/bash
cd /tmp

# Delay Vault start to allow consul to come up:
sleep 10
systemctl start vault

# Delay vault initialization
sleep 10

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /tmp/vault.txt
cat /tmp/vault.txt | jq -r '.unseal_keys_b64[0]' > /tmp/unseal_key
cat /tmp/vault.txt | jq -r .root_token > /tmp/root_token
export VAULT_TOKEN=$(cat /tmp/root_token)

sleep 20
vault operator unseal $(cat /tmp/unseal_key)
consul kv put vault_metadata/root_token ${VAULT_TOKEN}

# Adjust permissions
chown -R ubuntu /tmp
