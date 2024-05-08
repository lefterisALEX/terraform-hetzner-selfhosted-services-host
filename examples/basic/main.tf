terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

variable "hcloud_token" {}
variable "tailscale_auth_key" {}
variable "infisical_token" {
  default   = "st-xxx-xxx"
  sensitive = true
}
variable "infisical_client_id" {
  default   = "st-xxx-xxx"
}
variable "infisical_client_secret" {
  default   = "st-xxx-xxx"
}
variable "infisical_project_id" {
  default   = "st-xxx-xxx"
}


module "server" {
  source = "../.."

  name                     = "cloudstack-dev"
  ip_range                 = "10.222.0.0/24"
  server_ip                = "10.222.0.10"
  image                    = "ubuntu-22.04"
  server_type              = "cax11"
  region                   = "nbg1"
  network_zone             = "eu-central"
  volume_size              = 10
  public_access            = false
  volume_delete_protection = false
  tailscale_auth_key       = var.tailscale_auth_key
  enable_infisical         = true
  infisical_client_id      = var.infisical_client_id
  infisical_client_secret  = var.infisical_client_secret
  infisical_project_id     = var.infisical_project_id 

  timezone         = "Europe/Amsterdam"
  ssh_keys         = ["main"]
  tailscale_routes = "10.222.0.10/32,172.29.0.0/16"

  post_init_commands = [
    "apt-get update",
    "mkdir -p /backups",
  ]
}



