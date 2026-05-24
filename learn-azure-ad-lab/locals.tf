# A static private IP for the DC is required so the VNet DNS entry is stable.
# It must fall within the workload subnet — .10 is a safe pick that avoids
# Azure's reserved addresses (.1–.4) and leaves room to grow.
locals {
  dc_private_ip = cidrhost(var.workload_subnet_prefix, 10)
}
