
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

write_files:
  - path: /etc/systemd/system/deployr.service
    content: |
      [Unit]
      Description=Infisical Secrets Sync Service
      After=network.target
      
      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/deployr.sh
      
      [Install]
      WantedBy=multi-user.target
    permissions: '0644'
    owner: root:root
  
  - path: /etc/systemd/system/deployr.timer
    content: |
      [Unit]
      Description=Run Infisical Secrets Sync periodically
      
      [Timer]
      OnBootSec=3min
      OnUnitActiveSec=3m
      
      [Install]
      WantedBy=timers.target
    permissions: '0644'
    owner: root:root

  - path: /usr/local/bin/deployr.sh
    content: |
      #!/bin/bash

      # Load environment variables
      CLIENT_ID="${infisical_client_id}"
      CLIENT_SECRET="${infisical_client_secret}"
      PROJECT_ID="${infisical_project_id}"
      INFISICAL_API_URL="${infisical_api_url}"  

      # If INFISICAL_API_URL is set is going to export INFISICAL_API_URL
      if [ -n "$INFISICAL_API_URL" ]; then
        export INFISICAL_API_URL=$INFISICAL_API_URL
      fi

      # Base directory
      BASE_DIR="/root/deployr/${apps_directory}"
      # Log in to Infisical
      echo "Logging in to Infisical..."
      export INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id="$CLIENT_ID" --client-secret="$CLIENT_SECRET" --silent --plain)

      cd "$BASE_DIR"
      # Get the secrets of the root directory
      infisical export --env=prod --projectId="$PROJECT_ID" > ".secrets"

      # Iterate through each subdirectory  
      for dir in */; do
          # Check if it's a directory
          if [ -d "$dir" ]; then
              echo "Processing directory: $dir"

              # Export environment variables
              echo "Exporting environment variables for project ID: $PROJECT_ID in directory: $dir"
              infisical export --env=prod --path="/$dir" --projectId="$PROJECT_ID" > "$dir/.secrets"

              if [ $? -eq 0 ]; then
                  echo "Export successful for directory: $dir"
              else
                  echo "Error: Export failed for directory: $dir"
              fi
          else
              echo "Skipping non-directory: $dir"
          fi
      done

      # Fetch the latest changes
      git fetch

      # Check for new commits and pull if there are any
      if [ $(git rev-list HEAD...origin/main --count) -gt 0 ]; then
        echo "New commits found. Pulling changes..."
        git pull origin main
        docker-compose -f /root/deployr/${apps_directory}/docker-compose.yaml up -d
      else
        echo "No new commits found."
      fi
      echo "Script execution completed."
    permissions: '0755'
    owner: root:root

runcmd:
  - systemctl daemon-reload
  - systemctl enable deployr.timer
  - systemctl start deployr.timer

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
  
  # install extra-tools
  - curl https://rclone.org/install.sh | bash
  - apt-get install -y cifs-utils
  
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
  
  # Clone apps repo 
  - git clone ${apps_repository_url} /root/deployr
  # Get all secret
  - sh /usr/local/bin/deployr.sh
  # start containers
  - docker-compose -f /root/deployr/${apps_directory}/docker-compose.yaml up -d
  # User-provided custom runcmd commands
  # Append user-provided custom runcmd commands
%{ if custom_userdata != "" ~}
%{ for cmd in custom_userdata ~}
  - ${cmd}
%{ endfor ~}
%{ endif ~}
