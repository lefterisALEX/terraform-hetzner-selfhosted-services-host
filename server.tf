resource "hcloud_server" "this" {

  name         = var.name
  image        = var.image
  server_type  = var.server_type
  location     = var.region
  firewall_ids = var.public_access ? [] : [hcloud_firewall.this[0].id]
  ssh_keys     = concat(var.ssh_keys, ["server"])

  user_data = templatefile("${path.module}/scripts/bootstrap.sh", {
    tailscale_auth_key = var.tailscale_auth_key,
    linux_device       = hcloud_volume.this.linux_device
    tailscale_routes   = var.tailscale_routes
    timezone           = var.timezone
  })

  lifecycle {
    replace_triggered_by = [
      hcloud_volume.this.size
    ]
  }

  network {
    network_id = hcloud_network.this.id
    ip         = var.server_ip
  }

  depends_on = [
    hcloud_network_subnet.this
  ]

  public_net {
    ipv6_enabled = false
    ipv4_enabled = true
  }
}

resource "hcloud_volume" "this" {
  name              = "${var.name}-data"
  size              = var.volume_size
  location          = var.region
  automount         = false
  format            = "ext4"
  delete_protection = var.volume_delete_protection
}

resource "hcloud_volume_attachment" "this" {
  volume_id = hcloud_volume.this.id
  server_id = hcloud_server.this.id
  automount = false
}


resource "null_resource" "post-init" {
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
    inline = var.post_init_commands
  }

  depends_on = [
    hcloud_server.this,
  ]
}


# This is the key used by the runner to connect to the server.
resource "local_file" "ssh_private_key" {

  content         = tls_private_key.this.private_key_openssh
  filename        = "${path.root}/server.pem"
  file_permission = "0600"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "hcloud_ssh_key" "this" {
  name       = "server"
  public_key = tls_private_key.this.public_key_openssh
}