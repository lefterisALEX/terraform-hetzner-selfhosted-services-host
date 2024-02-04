
data "archive_file" "docker-files" {
  type        = "zip"
  source_dir  = "${path.root}/apps"
  output_path = "data.zip"
}

resource "null_resource" "docker-compose-files" {
  triggers = {
    src_hash  = "${data.archive_file.docker-files.output_sha}"
    server_id = hcloud_server.this.id
  }

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "root"
    private_key = tls_private_key.this.private_key_openssh
  }

  provisioner "file" {
    source      = "apps"
    destination = "/root"
  }

  depends_on = [
    hcloud_server.this,
    null_resource.post-init,
  ]
}


resource "null_resource" "docker-status" {
  triggers = {
    src_hash  = "${data.archive_file.docker-files.output_sha}"
    server_id = hcloud_server.this.id
  }

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "root"
    private_key = tls_private_key.this.private_key_openssh
  }


  provisioner "remote-exec" {
    inline = [
      "until  docker-compose version ; do echo 'docker compose is not setup yet...' ; sleep 5 ; done",
    ]
  }
  depends_on = [
    hcloud_server.this,
    null_resource.post-init,
  ]
}

resource "null_resource" "docker-secrets" {
  count = var.enable_infisical ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "root"
    private_key = tls_private_key.this.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "export INFISICAL_TOKEN=${var.infisical_token}",
      "for app_dir in /root/apps/*; do",
      "  if [ -d \"$app_dir\" ]; then",
      "    app_name=$(basename \"$app_dir\")",
      "    infisical export --env=prod --path=\"/$app_name\" > \"$app_dir/.secrets\"",
      "  fi",
      "done",
    ]
  }
  depends_on = [
    null_resource.docker-compose-files,
    null_resource.docker-status,
  ]
}


resource "null_resource" "docker-compose" {
  triggers = {
    src_hash  = "${data.archive_file.docker-files.output_sha}"
    server_id = hcloud_server.this.id
  }

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "root"
    private_key = tls_private_key.this.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f /root/apps/docker-compose.yaml up -d --remove-orphans --pull=always",
      "docker image prune -a -f",
    ]
  }
  depends_on = [
    null_resource.docker-compose-files,
    null_resource.docker-secrets,
    null_resource.docker-status,
  ]
}