<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-nxos-pim/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-nxos-pim/actions/workflows/test.yml)

# Terraform NX-OS PIM Module

Manages NX-OS PIM

Model Documentation: [Link](https://developer.cisco.com/docs/cisco-nexus-3000-and-9000-series-nx-api-rest-sdk-user-guide-and-api-reference-release-9-3x/#!configuring-pimpim6)

## Examples

```hcl
module "nxos_pim" {
  source  = "netascode/ospf/pim"
  version = ">= 0.1.0"

  vrfs = [
    {
      name        = "default"
      admin_state = true
      bfd         = true
      rps = [
        {
          address     = "20.1.1.1"
          group_range = "225.0.0.0/8"
          bidir       = false
          override    = false
        }
      ]
      anycast_rp_local_interface  = "lo1"
      anycast_rp_source_interface = "lo1"
      anycast_rps = [
        {
          address     = "20.1.1.1"
          set_address = "30.1.1.1"
        }
      ]
      interfaces = [
        {
          interface   = "vlan100"
          admin_state = true
          bfd         = true
          dr_priority = 10
          passive     = false
          sparse_mode = true
        }
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | >= 0.3.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nxos"></a> [nxos](#provider\_nxos) | >= 0.3.13 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_device"></a> [device](#input\_device) | A device name from the provider configuration. | `string` | `null` | no |
| <a name="input_vrfs"></a> [vrfs](#input\_vrfs) | PIM VRF list.<br>  Default value `admin_state`: `true`.<br>  Default value `bfd`: `false`.<br>  Default value `bidir`: `false`.<br>  Default value `override`: `false`.<br>  Default value `interfaces.admin_state`: `true`.<br>  Default value `interfaces.bfd`: `false`.<br>  Allowed values `dr_priority`: `1`-`4294967295`.<br>  Default value `dr_priority`: `1`.<br>  Default value `passive`: `false`.<br>  Default value `sparse_mode`: `false`. | <pre>list(object({<br>    name        = string<br>    admin_state = optional(bool)<br>    bfd         = optional(bool)<br>    rps = optional(list(object({<br>      address     = string<br>      group_range = optional(string)<br>      bidir       = optional(bool)<br>      override    = optional(bool)<br>    })))<br>    anycast_rp_local_interface  = optional(string)<br>    anycast_rp_source_interface = optional(string)<br>    anycast_rps = optional(list(object({<br>      address     = string<br>      set_address = string<br>    })))<br>    interfaces = optional(list(object({<br>      interface   = string<br>      admin_state = optional(bool)<br>      bfd         = optional(bool)<br>      dr_priority = optional(number)<br>      passive     = optional(bool)<br>      sparse_mode = optional(bool)<br>    })))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of the object. |

## Resources

| Name | Type |
|------|------|
| [nxos_pim.pimEntity](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim) | resource |
| [nxos_pim_anycast_rp.pimAcastRPFuncP](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_anycast_rp) | resource |
| [nxos_pim_anycast_rp_peer.pimAcastRPPeer](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_anycast_rp_peer) | resource |
| [nxos_pim_instance.pimInst](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_instance) | resource |
| [nxos_pim_interface.pimIf](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_interface) | resource |
| [nxos_pim_static_rp.pimStaticRP](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_static_rp) | resource |
| [nxos_pim_static_rp_group_list.pimRPGrpList](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_static_rp_group_list) | resource |
| [nxos_pim_static_rp_policy.pimStaticRPP](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_static_rp_policy) | resource |
| [nxos_pim_vrf.pimDom](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/pim_vrf) | resource |
<!-- END_TF_DOCS -->