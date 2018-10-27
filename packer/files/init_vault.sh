#! /bin/bash

# Delay vault initialization
sleep 30

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /tmp/vault.txt
cat /tmp/vault.txt | jq -r '.unseal_keys_b64[0]' > /tmp/unseal_key
cat /tmp/vault.txt | jq -r .root_token > /tmp/root_token
export VAULT_TOKEN=$(cat /tmp/root_token)
vault operator unseal $(cat /tmp/unseal_key)

# Import the Catalog policy
vault policy write catalog-policy /tmp/catalog.policy

# Setup Vault access for ubuntu user:
echo "export VAULT_ADDR=\"http://vault.service.consul:8200\"" >> /home/ubuntu/.bashrc
echo "export VAULT_TOKEN=$(cat /tmp/root_token)" >> /home/ubuntu/.bashrc
chown ubuntu /tmp/vault.txt
chown ubuntu /tmp/root_token
chown ubuntu /tmp/unseal_key
