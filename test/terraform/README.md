<!-- OTC-HEADER-START -->
# otc-code/gh-actions

<p align=right>⚙ 07.04.2023</p>

<summary>Table of contents</summary>


- [Overview](#overview)
- [Terraform Docs](#terraform-docs)
  * [Requirements](#requirements)
  * [Providers](#providers)
  * [Modules](#modules)
  * [Resources](#resources)
  * [Inputs](#inputs)
  * [Outputs](#outputs)
</details>
<!-- OTC-HEADER-END -->

# Overview

Loreme ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<!-- OTC-FOOTER-START -->
# Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.60.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.49.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.59.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common"></a> [common](#module\_common) | git::https://github.com/Ontracon/tfm-cloud-commons.git | 2.3.0 |

## Resources

| Name | Type |
|------|------|
| [random_pet.test](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_region"></a> [cloud\_region](#input\_cloud\_region) | Define the cloud region to use (AWS Region / Azure Location) which tf should use. | `string` | n/a | yes |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Set custom name for deployment. | `string` | `""` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Set custom tags for deployment. | `map(string)` | `null` | no |
| <a name="input_global_config"></a> [global\_config](#input\_global\_config) | Global config Object which contains the mandatory informations within OTC. | <pre>object({<br>    env             = string<br>    customer_prefix = string<br>    project         = string<br>    application     = string<br>    costcenter      = string<br>  })</pre> | n/a | yes |
| <a name="input_length"></a> [length](#input\_length) | n/a | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_name"></a> [custom\_name](#output\_custom\_name) | Outputs the custom name |
| <a name="output_pet"></a> [pet](#output\_pet) | Outputs the custom name |
<!-- END_TF_DOCS -->

<p align=right>Updated: https://github.com/otc-code/gh-actions/actions/runs/4637005925</p>

<!-- OTC-FOOTER-END -->
