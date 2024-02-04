output "server_id" {
  value = hcloud_server.this.id
}

output "server_ip" {
  value = hcloud_server.this.ipv4_address
}
