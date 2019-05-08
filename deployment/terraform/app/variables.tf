variable "aws_region" {}

variable "aws_profile" {}

variable "aws_account_name" {}

variable "aws_account_id" {}

variable "terragrunt_mgmt_s3_bucket" {}

variable "aws_mgmt_region" {}

variable "aws_mgmt_profile" {}

variable "aws_assume_role_arn" {}

variable "aws_mgmt_role_arn" {}

variable "environment" {}

variable "owner" {}

variable "project" {}

variable "securitylevel" {}

variable "tags" {
  type    = "map"
  default = {}
}

variable "eks_cluster_key_location" {
  description = "Custom remote-state key (S3) location for EKS Cluster"
  default     = ""
}

variable "vpc_key_location" {
  description = "Custom remote-state key (S3) location for VPC"
  default     = ""
}

variable "azs" {
  default = []
}
