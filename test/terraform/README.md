<!-- OTC-HEADER-START -->

# otc-code/gh-actions

<p align=right>⚙ 06.04.2023</p>
<details>
<summary>Table of contents</summary>

-   [Overview](#overview)
-   [Terraform Docs](#terraform-docs)
    -   [Requirements](#requirements)
    -   [Providers](#providers)
    -   [Modules](#modules)
    -   [Resources](#resources)
    -   [Inputs](#inputs)
    -   [Outputs](#outputs)
    -   [](#)
-   [Terraform Docs](#terraform-docs-1)
    </details>
    <!-- OTC-HEADER-END -->

# Overview

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<!-- OTC-FOOTER-START -->

# Terraform Docs

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | 4.60.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | 3.49.0  |
| <a name="requirement_google"></a> [google](#requirement_google)          | 4.59.0  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_random"></a> [random](#provider_random) | n/a     |

## Modules

| Name                                                  | Source                                                   | Version |
| ----------------------------------------------------- | -------------------------------------------------------- | ------- |
| <a name="module_common"></a> [common](#module_common) | git::<https://github.com/Ontracon/tfm-cloud-commons.git> | 2.3.0   |

## Resources

| Name                                                                                                  | Type     |
| ----------------------------------------------------------------------------------------------------- | -------- |
| [random_pet.test](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name                                                                     | Description                                                                       | Type                                                                                                                                                                                        | Default | Required |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_cloud_region"></a> [cloud_region](#input_cloud_region)    | Define the cloud region to use (AWS Region / Azure Location) which tf should use. | `string`                                                                                                                                                                                    | n/a     |    yes   |
| <a name="input_custom_name"></a> [custom_name](#input_custom_name)       | Set custom name for deployment.                                                   | `string`                                                                                                                                                                                    | `""`    |    no    |
| <a name="input_custom_tags"></a> [custom_tags](#input_custom_tags)       | Set custom tags for deployment.                                                   | `map(string)`                                                                                                                                                                               | `null`  |    no    |
| <a name="input_global_config"></a> [global_config](#input_global_config) | Global config Object which contains the mandatory informations within OTC.        | <pre>object({<br>    env             = string<br>    customer_prefix = string<br>    project         = string<br>    application     = string<br>    costcenter      = string<br>  })</pre> | n/a     |    yes   |
| <a name="input_length"></a> [length](#input_length)                      | n/a                                                                               | `number`                                                                                                                                                                                    | `3`     |    no    |

## Outputs

| Name                                                                 | Description             |
| -------------------------------------------------------------------- | ----------------------- |
| <a name="output_custom_name"></a> [custom_name](#output_custom_name) | Outputs the custom name |
| <a name="output_pet"></a> [pet](#output_pet)                         | Outputs the custom name |

## <!-- END_TF_DOCS -->

<p align=right>Updated: https://github.com/otc-code/gh-actions/actions/runs/4625241322</p>

<!-- OTC-FOOTER-END -->
