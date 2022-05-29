module "nxos_pim" {
  source  = "netascode/pim/nxos"
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
