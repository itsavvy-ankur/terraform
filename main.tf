terraform {
  backend "gcs" {
    bucket  = "tf-admin-242820"
    prefix  = "terraform/state/modules"
  }
}
module "vault-kms-unseal" {
  source = "./vault-kms-unseal"
}

#module "local-execs" {
#  source = "./local-execs"
#  external_network_ip = "${module.vault-kms-unseal.external_network_ip}"
#}

module "gke-dev" {
    source = "./gke-dev"
}