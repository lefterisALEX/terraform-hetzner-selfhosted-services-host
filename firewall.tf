resource "hcloud_firewall" "this" {
  count = var.public_access ? 0 : 1

  name = var.name
}
