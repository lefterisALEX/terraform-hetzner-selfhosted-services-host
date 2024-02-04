resource "hcloud_network" "this" {
  name     = var.name
  ip_range = var.ip_range
}

resource "hcloud_network_subnet" "this" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.ip_range
}
