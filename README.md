## Project Description

This project automates the deployment and management of selfhosted applications on a Hetzner cloud instance. 
It leverages Terraform to provision infrastructure, clones your code from a GitHub repository, manages secrets using Infisical, and utilizes Docker Compose for deploying your applications.
The setup ensures that applications are kept up-to-date with the latest code changes from your upstream repository.

## How it works

This setup is designed to function as a modular Docker Compose configuration, featuring a primary `docker-compose.yaml` file that incorporates additional child `docker-compose.yaml` files.
If Infisical integration is enabled:
 - An `.env` file is generated in the parent directory, containing all the secrets from the parent directory of your Infisical project.
 - A `.secret` file is created in each subdirectory, containing all the secrets from the directory with the same name as your Infisical project.
```
/
│
├── docker-compose.yaml           # Parent compose file
├── .env                          # Environment variables for parent compose file
│
├── traefik/
│   ├── docker-compose.yaml       # Child compose file
│   └── .secret                   # Secret variables for traefik
│
├── immich/
│   ├── docker-compose.yaml       # Child compose file
│   └── .secret                   # Secret variables for immich
│
└── uptime/
    ├── docker-compose.yaml       # Child compose file
    └── .secret                   # Secret variables for uptime

```

1. Deploys an instance in your Hetzner project, accessible via a pre-configured SSH key.
2. Clones your GitHub repository containing the `docker-compose` file(s).
3. Retrieves secrets from your Infisical project and saves them in a `.env` file for the root `docker-compose` file.
4. Retrieves secrets from your Infisical project and saves them in a `.secrets` file for each subdirectory in your repository.
5. Executes the root `docker-compose.yaml` file.
6. Regularly checks for new commits in the upstream repository. If new commits are found, it fetches the updated code and re-applies the `docker-compose.yaml`.



## Requirments
1. **Generate an API Token for your Hetzner project.**  
This will allow terraform to deploy resources in your hetzner project.  
*more info: https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/*  
2. **(Optional) Create an Auth-Key in your Tailscale account**  
This key will be used to connect the server to your Tailscale network.  
*More information: [Generating a Key](https://tailscale.com/kb/1085/auth-keys#generating-a-key)*  
3. **(Optional) Create a new Infisical machine identity to access secrets from your Infisical project.**  
More information: https://infisical.com/docs/documentation/platform/identities/universal-auth.
For detailed instructions on setting up Infisical secrets, please refer to the "How to setup and inject secrets from infisical" section below in this document.
4. **(Optional) Create a GitHub Token**  
   This token is necessary if your application repository is private.



## How to setup and inject secrets from infisical 

### Setup infisical

1. Navigate to Admin > Access Control > Identities and create a new Identity. Give the `Member` role to this identity.
1. Create a project and get the `project ID`. You will need to set it as `infisical_project_id`.
3. In `Access Control` > `Machine Identities` of your project Assign the newly created identity as a Project Viewer.
4. Click on Universal Auth, then click Add a `client secret`. Get the client secret and set it as `infisical_client_secret` 
5. Get the client ID and set it as `infisical_client_id`.
6. If you are in the EU data center, export the following environment variable: `INFISICAL_API_URL="https://eu.infisical.com"`.

The structure of the directories in infisical project should match the structure of directories in the `apps` directory.   
Let's say you want to inject the secret `DB_PASSWORD`  as environment variable for the app `immich`.

1.Under `immich` directory create the key `DB_PASSWORD` with the value you want to inject to the app
![image](https://github.com/lefterisALEX/terraform-hetzner-cloudstack/assets/24940221/be99c504-ac31-4dfd-8df1-9fe8cfcad435)
![image](https://github.com/lefterisALEX/terraform-hetzner-cloudstack/assets/24940221/815efc22-e400-4a43-a091-bce4398eea05)

2.  `Update docker-compose.yaml` to pass the content of the `.secrets` file as environment variables.

![image](https://github.com/lefterisALEX/terraform-hetzner-cloudstack/assets/24940221/168247b7-944f-4b12-8918-625fa7644d43)

Note:  What will happened is when you run terraform apply infisical ig going to read all secrets under each infisical project and export it under each directory with same name to a file called `.secrets`
For example if you have under apps three directories, `immich`, `traefik` and `photoprism` the module is going to generate for each directory a file called `.secrets`  

![image](https://github.com/lefterisALEX/terraform-hetzner-cloudstack/assets/24940221/c22e4d31-0239-4a28-b83a-ec8d722b4649)


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_server.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_volume.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [hcloud_volume_attachment.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_userdata"></a> [custom\_userdata](#input\_custom\_userdata) | Extra commands to be executed in cloud-init | `list(string)` | <pre>[<br/>  "echo 'Default user-data execution'"<br/>]</pre> | no |
| <a name="input_docker_compose_path"></a> [docker\_compose\_path](#input\_docker\_compose\_path) | The relative path in your repo where docker compose file is. | `string` | `"examples/basic/apps"` | no |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | The URL of the applications repository. | `string` | `""` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | The GitHub token for accessing private repositories. | `string` | `""` | no |
| <a name="input_hcloud_network_id"></a> [hcloud\_network\_id](#input\_hcloud\_network\_id) | The network ID from your private network | `number` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The image the server is created from. | `string` | `"ubuntu-22.04"` | no |
| <a name="input_infisical_api_url"></a> [infisical\_api\_url](#input\_infisical\_api\_url) | The infisical api URL. This value will be exported to INFISICAL\_API\_URL if set | `string` | `null` | no |
| <a name="input_infisical_client_id"></a> [infisical\_client\_id](#input\_infisical\_client\_id) | The infisical client id. | `string` | `""` | no |
| <a name="input_infisical_client_secret"></a> [infisical\_client\_secret](#input\_infisical\_client\_secret) | The infisical client secret. | `string` | `""` | no |
| <a name="input_infisical_project_id"></a> [infisical\_project\_id](#input\_infisical\_project\_id) | The infisical project ID. | `string` | `""` | no |
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | The IP range of the network. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of your server | `string` | `"server"` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The private key which can be used to connect to the server. | `string` | `""` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | If false a firewall that block all public access will be attached to the server. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The cloud region where resources will be deployed. | `string` | `"nbg1"` | no |
| <a name="input_root_disk_size"></a> [root\_disk\_size](#input\_root\_disk\_size) | The size of the main disk in GB for the instance. | `number` | `80` | no |
| <a name="input_server_ip"></a> [server\_ip](#input\_server\_ip) | The IP of the interface which will be attached to your server. | `string` | `"10.10.0.2"` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | The server type this server should be created with. | `string` | `"cax11"` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | A list of SSH key names which will be imported while creating the server | `list(string)` | `[]` | no |
| <a name="input_tailscale_auth_key"></a> [tailscale\_auth\_key](#input\_tailscale\_auth\_key) | The auth key for your tailscale network | `string` | `""` | no |
| <a name="input_tailscale_routes"></a> [tailscale\_routes](#input\_tailscale\_routes) | The routes which will be advertised in the tailscale network. | `string` | `"10.10.0.2/32"` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The timezone which the server will be configured. | `string` | `"Europe/Amsterdam"` | no |
| <a name="input_volume_delete_protection"></a> [volume\_delete\_protection](#input\_volume\_delete\_protection) | If set to true is going to protect volume from deletion. | `bool` | `false` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the volume which will be attached to the server | `string` | `"15"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | n/a |
| <a name="output_server_ip"></a> [server\_ip](#output\_server\_ip) | n/a |


