#!/bin/bash

echo "Hello Consul Server!"

# Install Consul.  This creates...
# 1 - a default /etc/consul.d/consul.hcl
# 2 - a default systemd consul.service file
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && apt install -y consul

# Grab instance IP
local_ip=$(ip -o route get to 169.254.169.254 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')

# Modify the default consul.hcl file
cat > /etc/consul.d/consul.hcl <<- EOF
data_dir = "/opt/consul"

client_addr = "0.0.0.0"

ui_config {
  enabled = true
}

server = true

bind_addr = "0.0.0.0"

advertise_addr = "$local_ip"

bootstrap_expect=${BOOTSTRAP_NUMBER}

retry_join = ["provider=aws tag_key=\"${PROJECT_TAG}\" tag_value=\"${PROJECT_VALUE}\""]

encrypt = "${GOSSIP_KEY}"

EOF

# Start Consul
sudo systemctl start consul