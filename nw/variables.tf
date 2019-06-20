variable "project_id" {
  description = "The project ID to host the network in"
  default = "tf-admin-242820"
}

variable "network_name" {
  description = "The name of the VPC network being created"
  default = "gke-dev-nw"
}