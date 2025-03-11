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

variable "hcloud_token" {
  type = string
}
variable "tailscale_auth_key" {
  type = string
}
variable "infisical_client_id" {
  type = string
  default   = ""
  sensitive = true
}
variable "infisical_client_secret" {
  type = string
  default   = ""
  sensitive = true
}
variable "infisical_project_id" {
  type = string
  default   = ""
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}


module "server" {
  source = "../.."

  name                     = "cloudstack-dev-2"
  image                    = "ubuntu-22.04"
  server_type              = "cax11"
  region                   = "nbg1"
  volume_size              = 10
  hcloud_network_id        = 10756354
  server_ip                = "10.122.0.10"
  public_access            = false
  volume_delete_protection = false
  tailscale_auth_key       = var.tailscale_auth_key
  enable_infisical         = true
  infisical_client_id      = var.infisical_client_id
  infisical_client_secret  = var.infisical_client_secret
  infisical_project_id     = var.infisical_project_id 
  infisical_api_url        = "https://eu.infisical.com"   
  github_repo_url          = "https://github.com/lefterisALEX/terraform-hetzner-cloudstack.git"
  github_token             = var.github_token


  timezone         = "Europe/Amsterdam"
  ssh_keys         = ["main"]
  tailscale_routes = "10.122.0.10/32,172.29.0.0/16"
  custom_userdata = [
     "echo 'Custom user-data execution'",
     "mkdir /mnt/custom_data",
     "apt-get install -y btop"
  ]
}


