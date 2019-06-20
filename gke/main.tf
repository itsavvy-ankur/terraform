terraform {
  backend "gcs" {
    bucket  = "tf-admin-242820"
    prefix  = "terraform/state"
  }
}
module "gke-dev" {
  source = "./gke-dev"
}