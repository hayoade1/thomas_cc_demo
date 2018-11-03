#! /bin/bash

# Install envconsul on Linux:
export envconsul_version=0.7.3
curl -so envconsul.tgz https://releases.hashicorp.com/envconsul/${envconsul_version}/envconsul_${envconsul_version}_linux_amd64.tgz
tar -xvzf envconsul.tgz
sudo mv envconsul /usr/local/bin/envconsul
sudo chmod +x /usr/local/bin/envconsul
envconsul --version

# Install Consul-template on Linux:
export consultemplate_version=0.19.5
curl -so consul-template.tgz https://releases.hashicorp.com/consul-template/${consultemplate_version}/consul-template_${consultemplate_version}_linux_amd64.tgz
tar -xvzf consul-template.tgz
sudo mv consul-template /usr/local/bin/consul-template
sudo chmod +x /usr/local/bin/consul-template
consul-template --version
