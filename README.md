<!-- BEGIN_TF_DOCS -->
## Information
Create an instance in your Hetzner project that you can access with a provided SSH key.
The instance will run your docker compose files under apps directory.

## Requirments
1. **Generate an API Token for your Hetzner project.**  
This will allow terraform to deploy resources in your hetzner project.  
*more info: https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/*  
2. **(Optional) Create an Auth-Key in your taisclale account**  
This will be used to join the server in your tailscale network.   
*more info: https://tailscale.com/kb/1085/auth-keys#generating-a-key*  
3. **(Optional)Create a service token in your infisical project.**  
This will be used to get secrets from your infisical project.  
When you create the token you need to set as below:  
![image](https://github.com/lefterisALEX/terraform-hetzner-cloudstack/assets/24940221/de485df8-245e-4052-a469-5c9cb0c9631e)

*more info:  https://infisical.com/docs/internals/service-tokens* 


**How to inject secrets from infisical**  
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


## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_network.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_server.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [hcloud_volume.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [hcloud_volume_attachment.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume_attachment) | resource |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.docker-compose](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.docker-compose-files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.docker-secrets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.docker-status](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.post-init](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [archive_file.docker-files](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | (Required) The API key for your hetzner project. | `string` | `""` | yes |
| <a name="input_enable_infisical"></a> [enable\_infisical](#input\_enable\_infisical) | Set to true to enable accessing secrets from infisical. | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | The image the server is created from. | `string` | `"ubuntu-22.04"` | no |
| <a name="input_infisical_token"></a> [infisical\_token](#input\_infisical\_token) | An access token from your infisical project. | `string` | `"st-xxx-xx"` | no |
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | The IP range of the network. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of your server | `string` | `"server"` | no |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | The zone where network resources will be created. | `string` | `"eu-central"` | no |
| <a name="input_post_init_commands"></a> [post\_init\_commands](#input\_post\_init\_commands) | A set of commands to be executed everytime terraform runs. | `list(string)` | `[]` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The private key which can be used to connect to the server. | `string` | `""` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | If false a firewall that block all public access will be attached to the server. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The cloud region where resources will be deployed. | `string` | `"nbg1"` | no |
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
<!-- END_TF_DOCS -->
