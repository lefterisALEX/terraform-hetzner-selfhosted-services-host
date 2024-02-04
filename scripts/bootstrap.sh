
#cloud-config
# This example assumes a default Ubuntu cloud image, which should contain
# the required software to be managed remotely by Ansible.

package_update: true
package_update: false
package_upgrade: true

#Do not accept SSH password authention
ssh_pwauth: false

timezone: ${timezone}
packages:
  - jq
  - nfs-common

runcmd:
- mkdir  /mnt/data
- mount -o discard,defaults ${linux_device} /mnt/data
- echo "${linux_device} /mnt/data ext4 discard,nofail,defaults 0 0" >> /etc/fstab


# install tailscale
- curl -fsSL https://tailscale.com/install.sh | sh
- tailscale up --advertise-routes="${tailscale_routes}" --accept-routes --auth-key="${tailscale_auth_key}"

# Infisical
- curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' |  bash
- apt-get update
- apt-get install -y infisical

# install rclone
- curl https://rclone.org/install.sh | bash

# setup ufw
- ufw allow OpenSSH
- ufw --force enable

# Docker install
- curl -fsSL https://get.docker.com -o get-docker.sh
- sh get-docker.sh
- systemctl daemon-reload
- systemctl restart docker
- systemctl enable docker
- printf '\nDocker installed successfully\n\n'
- printf 'Waiting for Docker to start...\n\n'
- sleep 5

# Docker Compose
- COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
- curl -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
- chmod +x /usr/local/bin/docker-compose
- curl -L https://raw.githubusercontent.com/docker/compose/$COMPOSE_VERSION/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
- printf '\nDocker Compose installed successfully\n\n'
- docker-compose -v
