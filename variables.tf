variable "name" {
  default     = "server"
  type        = string
  description = "The name of your server"
}

variable "tailscale_auth_key" {
  default     = ""
  type        = string
  sensitive   = true
  description = "The auth key for your tailscale network"
}

variable "tailscale_routes" {
  default     = "10.10.0.2/32"
  type        = string
  description = "The routes which will be advertised in the tailscale network."
}

variable "region" {
  default     = "nbg1"
  type        = string
  description = "The cloud region where resources will be deployed."
}

variable "hcloud_network_id" {
  type = number
  description = "The network ID from your private network"
}

variable "image" {
  default     = "ubuntu-24.04"
  type        = string
  description = "The image the server is created from."
}

variable "server_type" {
  default     = "cax11"
  type        = string
  description = "The server type this server should be created with."
}

variable "server_ip" {
  default     = "10.10.0.2"
  type        = string
  description = "The IP of the interface which will be attached to your server."
}

variable "volume_size" {
  default     = "15"
  type        = number
  description = "The size of the volume which will be attached to the server"
}

variable "volume_delete_protection" {
  default     = false
  type        = bool
  description = "If set to true is going to protect volume from deletion."
}

variable "timezone" {
  default     = "Europe/Amsterdam"
  type        = string
  description = "The timezone which the server will be configured."
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "A list of SSH key names which will be imported while creating the server"
}

variable "public_access" {
  type        = bool
  default     = false
  description = "If false a firewall that block all public access will be attached to the server."
}

variable "infisical_client_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The infisical client id."
}

variable "infisical_client_secret" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The infisical client secret."
}

variable "infisical_project_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The infisical project ID."
}

variable "infisical_api_url" {
  type        = string
  default     = "https://app.infisical.com"
  description = "The infisical api URL. This value will be exported to INFISICAL_API_URL if set"
}

variable "github_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The GitHub token for accessing private repositories."
}

variable "github_repo_url" {
  type        = string
  default     = ""
  description = "The URL of the applications repository."
}

variable "docker_compose_path" {
  type        = string
  default     = "examples/basic/apps"
  description = "The relative path in your repo where the parent docker compose file is."
}
variable "custom_userdata" {
  description = "Extra commands to be executed in cloud-init"
  type        = list(string)
  default     = [
    "echo 'Default user-data execution'"
  ]
}
