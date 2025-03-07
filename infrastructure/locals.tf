locals {
  subnet_private_cdir = cidrsubnet(var.cidr_range, 8, 1)
  subnet_vpn_cdir = cidrsubnet(var.cidr_range, 8, 7)
  subnet_public_cdir = cidrsubnet(var.cidr_range, 8, 8)
}