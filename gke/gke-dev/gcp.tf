// Configure the Google Cloud provider
provider "google" {
  project     = "${var.gcp-project}"
  region      = "${var.gcp-region}"
}