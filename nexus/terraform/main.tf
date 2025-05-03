terraform {
  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "2.5.0"
    }
  }
}

provider "nexus" {
  insecure = true
  password = "<nexus admin password>"
  url      = "<nexus url>"
  username = "<nexus user>"
}