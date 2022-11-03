/*
terraform {
  backend "s3" {
    bucket = "dawid-terra"
    key    = "ted-search/terraform.tfstate"
    region = "eu-central-1"
  }
}
*/

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
}

module "network" {
  source = "./modules/network"
  name   = var.name
}

module "app" {
  depends_on  = [module.network]
  source      = "./modules/app"
  subnet_id   = module.network.subnet_id
  vpc_id      = module.network.vpc_id
  name        = var.name
  private_key = var.private_key
}
