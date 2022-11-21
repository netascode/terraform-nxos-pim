terraform {
  required_version = ">= 1.3.0"

  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "netascode/nxos"
      version = ">=0.3.13"
    }
  }
}

# requirement
resource "nxos_feature_pim" "fmPim" {
  admin_state = "enabled"
}

module "main" {
  source = "../.."

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
          bfd         = "enabled"
          dr_priority = 10
          passive     = false
          sparse_mode = true
        }
      ]
    }
  ]

  depends_on = [
    nxos_feature_pim.fmPim
  ]
}

data "nxos_pim" "pimEntity" {
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim" {
  component = "nxos_pim"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_pim.pimEntity.admin_state
    want        = "enabled"
  }
}

data "nxos_pim_instance" "pimInst" {
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_instance" {
  component = "nxos_pim_instance"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_pim_instance.pimInst.admin_state
    want        = "enabled"
  }
}

data "nxos_pim_vrf" "pimDom" {
  name       = "default"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_vrf" {
  component = "nxos_pim_vrf"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_pim_vrf.pimDom.admin_state
    want        = "enabled"
  }

  equal "bfd" {
    description = "bfd"
    got         = data.nxos_pim_vrf.pimDom.bfd
    want        = true
  }
}

data "nxos_pim_static_rp_policy" "pimStaticRPP" {
  vrf_name   = "default"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_static_rp_policy" {
  component = "nxos_pim_static_rp_policy"

  equal "name" {
    description = "name"
    got         = data.nxos_pim_static_rp_policy.pimStaticRPP.name
    want        = "RP"
  }
}

data "nxos_pim_static_rp" "pimStaticRP" {
  vrf_name   = "default"
  address    = "20.1.1.1"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_static_rp" {
  component = "nxos_pim_static_rp"

  equal "address" {
    description = "address"
    got         = data.nxos_pim_static_rp.pimStaticRP.address
    want        = "20.1.1.1"
  }
}

data "nxos_pim_static_rp_group_list" "pimRPGrpList" {
  vrf_name   = "default"
  rp_address = "20.1.1.1"
  address    = "225.0.0.0/8"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_static_rp_group_list" {
  component = "nxos_pim_static_rp_group_list"

  equal "address" {
    description = "address"
    got         = data.nxos_pim_static_rp_group_list.pimRPGrpList.address
    want        = "225.0.0.0/8"
  }

  equal "bidir" {
    description = "bidir"
    got         = data.nxos_pim_static_rp_group_list.pimRPGrpList.bidir
    want        = false
  }

  equal "override" {
    description = "override"
    got         = data.nxos_pim_static_rp_group_list.pimRPGrpList.override
    want        = false
  }
}

data "nxos_pim_anycast_rp" "pimAcastRPFuncP" {
  vrf_name   = "default"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_pim_anycast_rp" {
  component = "nxos_pim_anycast_rp"

  equal "local_interface" {
    description = "local_interface"
    got         = data.nxos_pim_anycast_rp.pimAcastRPFuncP.local_interface
    want        = "lo1"
  }

  equal "source_interface" {
    description = "source_interface"
    got         = data.nxos_pim_anycast_rp.pimAcastRPFuncP.source_interface
    want        = "lo1"
  }
}

data "nxos_pim_anycast_rp_peer" "pimAcastRPPeer" {
  vrf_name       = "default"
  address        = "20.1.1.1"
  rp_set_address = "30.1.1.1"
  depends_on     = [module.main]
}

resource "test_assertions" "nxos_pim_anycast_rp_peer" {
  component = "nxos_pim_anycast_rp_peer"

  equal "address" {
    description = "address"
    got         = data.nxos_pim_anycast_rp_peer.pimAcastRPPeer.address
    want        = "20.1.1.1"
  }

  equal "rp_set_address" {
    description = "rp_set_address"
    got         = data.nxos_pim_anycast_rp_peer.pimAcastRPPeer.rp_set_address
    want        = "30.1.1.1"
  }
}

data "nxos_pim_interface" "pimIf" {
  vrf_name     = "default"
  interface_id = "vlan100"
  depends_on   = [module.main]
}

resource "test_assertions" "nxos_pim_interface" {
  component = "nxos_pim_interface"

  equal "interface_id" {
    description = "interface_id"
    got         = data.nxos_pim_interface.pimIf.interface_id
    want        = "vlan100"
  }

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_pim_interface.pimIf.admin_state
    want        = "enabled"
  }

  equal "bfd" {
    description = "bfd"
    got         = data.nxos_pim_interface.pimIf.bfd
    want        = "enabled"
  }

  equal "dr_priority" {
    description = "dr_priority"
    got         = data.nxos_pim_interface.pimIf.dr_priority
    want        = 10
  }

  equal "passive" {
    description = "passive"
    got         = data.nxos_pim_interface.pimIf.passive
    want        = false
  }

  equal "sparse_mode" {
    description = "sparse_mode"
    got         = data.nxos_pim_interface.pimIf.sparse_mode
    want        = true
  }
}
