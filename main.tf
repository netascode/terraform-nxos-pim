locals {
  rp_map = merge([
    for vrf in var.vrfs : vrf.rps == null ? {} : {
      for rp in vrf.rps : "${vrf.name}_${rp.address}" => merge(rp, { "vrf" : vrf.name })
    }
  ]...)
  anycast_rp_map = merge([
    for vrf in var.vrfs : vrf.anycast_rps == null ? {} : {
      for rp in vrf.anycast_rps : "${vrf.name}_${rp.address}_${rp.set_address}" => merge(rp, { "vrf" : vrf.name })
    }
  ]...)
  interface_map = merge([
    for vrf in var.vrfs : vrf.interfaces == null ? {} : {
      for interface in vrf.interfaces : "${vrf.name}_${interface.interface}" => merge(interface, { "vrf" : vrf.name })
    }
  ]...)
}

resource "nxos_pim" "pimEntity" {
  device      = var.device
  admin_state = "enabled"
}

resource "nxos_pim_instance" "pimInst" {
  device      = var.device
  admin_state = "enabled"

  depends_on = [
    nxos_pim.pimEntity
  ]
}

resource "nxos_pim_vrf" "pimDom" {
  for_each    = { for v in var.vrfs : v.name => v }
  device      = var.device
  name        = each.value.name
  admin_state = each.value.admin_state == null || each.value.admin_state == true ? "enabled" : "disabled"
  bfd         = each.value.bfd != null ? each.value.bfd : false

  depends_on = [
    nxos_pim_instance.pimInst
  ]
}

resource "nxos_pim_static_rp_policy" "pimStaticRPP" {
  for_each = { for v in var.vrfs : v.name => v if length(v.rps) > 0 }
  device   = var.device
  vrf_name = nxos_pim_vrf.pimDom[each.key].name
  name     = "RP"
}

resource "nxos_pim_static_rp" "pimStaticRP" {
  for_each = local.rp_map
  device   = var.device
  vrf_name = nxos_pim_static_rp_policy.pimStaticRPP[each.value.vrf].vrf_name
  address  = each.value.address
}

resource "nxos_pim_static_rp_group_list" "pimRPGrpList" {
  for_each   = local.rp_map
  device     = var.device
  vrf_name   = nxos_pim_static_rp.pimStaticRP[each.key].vrf_name
  rp_address = nxos_pim_static_rp.pimStaticRP[each.key].address
  address    = each.value.group_range != null ? each.value.group_range : "224.0.0.0/4"
  bidir      = each.value.bidir != null ? each.value.bidir : false
  override   = each.value.override != null ? each.value.override : false
}

resource "nxos_pim_anycast_rp" "pimAcastRPFuncP" {
  for_each         = { for v in var.vrfs : v.name => v }
  device           = var.device
  vrf_name         = nxos_pim_vrf.pimDom[each.key].name
  local_interface  = each.value.anycast_rp_local_interface
  source_interface = each.value.anycast_rp_source_interface
}

resource "nxos_pim_anycast_rp_peer" "pimAcastRPPeer" {
  for_each       = local.anycast_rp_map
  device         = var.device
  vrf_name       = nxos_pim_anycast_rp.pimAcastRPFuncP[each.value.vrf].vrf_name
  address        = "${each.value.address}/32"
  rp_set_address = "${each.value.set_address}/32"
}

resource "nxos_pim_interface" "pimIf" {
  for_each     = local.interface_map
  device       = var.device
  vrf_name     = nxos_pim_vrf.pimDom[each.value.vrf].name
  interface_id = each.value.interface
  admin_state  = each.value.admin_state == null || each.value.admin_state == true ? "enabled" : "disabled"
  bfd          = each.value.bfd != null ? (each.value.bfd == "unspecified" ? "none" : each.value.bfd) : "none"
  dr_priority  = each.value.dr_priority != null ? each.value.dr_priority : 1
  passive      = each.value.passive != null ? each.value.passive : false
  sparse_mode  = each.value.sparse_mode != null ? each.value.sparse_mode : false
}
