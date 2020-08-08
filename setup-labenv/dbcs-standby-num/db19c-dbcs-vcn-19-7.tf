variable "tenancy_ocid" {}
variable "region" {}


variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "num_instances" {
  default = "1"
}

terraform {
  required_version = ">= 0.12.0"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  region       = "${var.region}"
}


variable "VCN-example" { default = "10.0.0.0/16" }

##
# DBCS Variables
##

variable "db_admin_password" {
  description = "Database Administrator User Password"
}

variable "storage_management" {
  default = "LVM"
	description = "Database storage management: LVM or ASM"
}

variable "db_system_shape" {
  default = "VM.Standard2.2"
}

variable "db_edition" {
  default = "ENTERPRISE_EDITION_EXTREME_PERFORMANCE"
}

variable "db_version" {
  default = "19.7.0.0"
}

variable "db_workload" {
  default = "OLTP"
}

variable "db_name" {
	default = "ORCL"
}

variable "pdb_name" {
  default = "orclpdb"
}

variable "license_model" {
  default = "BRING_YOUR_OWN_LICENSE"
}



resource "oci_core_virtual_network" "example-vcn" {
  cidr_block     = "${var.VCN-example}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "standby-vcn"
  dns_label      = "standbyvcn"
}

# --- Create a new Internet Gateway
resource "oci_core_internet_gateway" "example-ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "standby-internet-gateway"
  vcn_id         = "${oci_core_virtual_network.example-vcn.id}"
}
#---- Create Route Table
resource "oci_core_route_table" "example-rt" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.example-vcn.id}"
  display_name   = "standby-route-table"
  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.example-ig.id}"
  }
}

#--- Create a public Subnet 1 in AD1 in the new vcn
resource "oci_core_subnet" "example-public-subnet1" {
  #availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
  availability_domain = "${data.oci_identity_availability_domain.local_ad.name}"
  cidr_block          = "10.0.1.0/24"
  display_name        = "standby-public-subnet1"
  dns_label           = "subnet1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.example-vcn.id}"
  route_table_id      = "${oci_core_route_table.example-rt.id}"
  dhcp_options_id     = "${oci_core_virtual_network.example-vcn.default_dhcp_options_id}"
}


#--- Defualt  Network Security List

resource "oci_core_default_security_list" "default-security-list" {
  manage_default_resource_id = "${oci_core_virtual_network.example-vcn.default_security_list_id}"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }


  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 1521
      max = 1521
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }

  }
}


# Get the local Availability Domain
data "oci_identity_availability_domain" "local_ad" {
  compartment_id = "${var.tenancy_ocid}"
  ad_number      = 1
}


##
# Create DBCS VM
##

resource "oci_database_db_system" "db_system" {
  count               = "${var.num_instances}"
  availability_domain = "${data.oci_identity_availability_domain.local_ad.name}"
  compartment_id      = "${var.compartment_ocid}"
  database_edition    = "${var.db_edition}"

  db_home {
    database {
      admin_password = "${var.db_admin_password}"
      db_name        = "${var.db_name}"
      character_set  = "AL32UTF8"
      ncharacter_set = "AL16UTF16"
      db_workload    = "${var.db_workload}"
      pdb_name       = "${var.pdb_name}"

      db_backup_config {
        auto_backup_enabled = false
      }
    }

    db_version   = "${var.db_version}"
    display_name = "DBCS${count.index}"
  }

  db_system_options {
    storage_management = "${var.storage_management}"
  }

  shape                   = "${var.db_system_shape}"
  subnet_id               = "${oci_core_subnet.example-public-subnet1.id}"
  ssh_public_keys         = ["${var.ssh_public_key}"]
  display_name            = "DBCS${count.index}"
  hostname                = "DBCS${count.index}"
  data_storage_size_in_gb = "256"
  license_model           = "${var.license_model}"
  node_count              = "1"
}

