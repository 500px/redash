provider "aws" {
  region                      = "${var.aws_region}"
  profile                     = "${var.aws_profile}"
  skip_credentials_validation = true

  assume_role {
    role_arn     = "${var.aws_assume_role_arn}"
    session_name = "${var.aws_account_name}"
  }
}

terraform {
  backend "s3" {}
}

module "500px" {
  # required tags
  source        = "git::git@github.com:500px/lux-modules.git?ref=71aa61e6560f987ff543ff1a7e8ef0961f2096b6//500px-tags"
  role          = "infrastructure"
  owner         = "${var.owner}"
  project       = "${var.project}"
  application   = "redash"
  environment   = "${var.environment}"
  securitylevel = "${var.securitylevel}"

  # optional tags
  tags = "${var.tags}"
}

# Pull in outputs/remote state of eks-cluster
locals {
  eks_cluster_key_default = "${var.aws_account_name}/${var.aws_region}/_global/eks-cluster/terraform.tfstate"
  eks_cluster_key         = "${var.eks_cluster_key_location == "" ? local.eks_cluster_key_default : var.eks_cluster_key_location}"
}

data "terraform_remote_state" "eks_cluster" {
  backend = "s3"

  config {
    bucket   = "${var.terragrunt_mgmt_s3_bucket}"
    key      = "${local.eks_cluster_key}"
    profile  = "${var.aws_mgmt_profile}"
    role_arn = "${var.aws_mgmt_role_arn}"
    region   = "${var.aws_mgmt_region}"
  }
}

# Pull in outputs/remote state of vpc
locals {
  vpc_key_default = "${var.aws_account_name}/${var.aws_region}/_global/vpc/terraform.tfstate"
  vpc_key         = "${var.vpc_key_location == "" ? local.vpc_key_default : var.vpc_key_location}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket   = "${var.terragrunt_mgmt_s3_bucket}"
    key      = "${local.vpc_key}"
    profile  = "${var.aws_mgmt_profile}"
    role_arn = "${var.aws_mgmt_role_arn}"
    region   = "${var.aws_mgmt_region}"
  }
}

# Create IAM role to interact with KMS
data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars {
    key_arn = "${data.terraform_remote_state.eks_cluster.eks_kms_key_arn}"
  }
}

module "redash_role" {
  source              = "git@github.com:500px/lux-modules.git?ref=a3da81a8211f26961dd85ce7bbad611376004d7c//eks-app-role"
  name                = "redash"
  description         = "Role for doing decryption with KMS"
  aws_region          = "${var.aws_region}"
  policy              = "${data.template_file.policy.rendered}"
  eks_worker_role_arn = "${data.terraform_remote_state.eks_cluster.eks_worker_role_arn}"
  tags                = "${module.500px.tags}"
}
