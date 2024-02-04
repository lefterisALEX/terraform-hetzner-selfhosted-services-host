<!-- BEGIN_TF_DOCS -->
## Information
Create am instance in your Hetzner project that you can access with a provided SSH key.
The instance will run your docker compose files under apps directory.
## Usage
```
$ terraform init
$ terraform plan
$ terraform apply
```

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_server"></a> [server](#module\_server) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | n/a |
| <a name="output_server_ip"></a> [server\_ip](#output\_server\_ip) | n/a |
<!-- END_TF_DOCS -->
