
#cloud-config
# This example assumes a default Ubuntu cloud image, which should contain
# the required software to be managed remotely by Ansible.

package_update: true
package_upgrade: true

#Do not accept SSH password authention
ssh_pwauth: false

timezone: ${timezone}
packages:
  - jq
  - nfs-common

write_files:
  - path: /root/.deployr/.env
    content: |
      CLIENT_ID="${infisical_client_id}"
      CLIENT_SECRET="${infisical_client_secret}"
      PROJECT_ID="${infisical_project_id}"
      INFISICAL_API_URL="${infisical_api_url}"  
      DOCKER_COMPOSE_PATH="${docker_compose_path}"
    permissions: '0644'
    owner: root:root

runcmd:
  # Infisical
  - curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' |  bash
  - apt-get update
  - apt-get install -y infisical

  - mkdir  /mnt/data
  - mount -o discard,defaults ${linux_device} /mnt/data
  - echo "${linux_device} /mnt/data ext4 discard,nofail,defaults 0 0" >> /etc/fstab
  
  
  # install tailscale
  - curl -fsSL https://tailscale.com/install.sh | sh
  - tailscale up --advertise-routes="${tailscale_routes}" --accept-routes --auth-key="${tailscale_auth_key}"
  
  # install extra-tools
  - curl https://rclone.org/install.sh | bash
  - apt-get install -y cifs-utils
  
  # setup ufw
  - ufw allow OpenSSH
  - ufw --force enable
  
  # # Docker install
  - wget -O /tmp/v"${deployr_version}".tar.gz  https://github.com/lefterisALEX/docker-compose-deployr/archive/refs/tags/v"${deployr_version}".tar.gz
  - tar -xzvf /tmp/v"${deployr_version}".tar.gz -C /tmp
  - sh /tmp/docker-compose-deployr-"${deployr_version}"/helpers/docker-ubuntu.sh
  - (cd /tmp/docker-compose-deployr-"${deployr_version}" && chmod +x setup.sh && ./setup.sh)

  # Clone apps repo 
  - git clone ${apps_repository_url} /root/deployr
  # Get all secret
  - sh /usr/local/bin/deployr.sh
  # start containers
  - docker compose -f /root/deployr/"${docker_compose_path}"/docker-compose.yaml up -d
  # User-provided custom runcmd commands
  # Append user-provided custom runcmd commands
%{ if custom_userdata != "" ~}
%{ for cmd in custom_userdata ~}
  - ${cmd}
%{ endfor ~}
%{ endif ~}
