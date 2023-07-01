terraform {
  required_version = ">= 1.3.0"

  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "CiscoDevNet/nxos"
      version = ">= 0.5.0"
    }
  }
}

# requirement
resource "nxos_feature_pim" "fmPim" {
  admin_state = "enabled"
}

module "main" {
  source = "../.."

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
