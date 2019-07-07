terraform {
  backend "gcs" {
    bucket  = "tf-admin-242820"
    prefix  = "terraform/state/gke-dev"
  }
}

resource "google_container_cluster" "gke-dev" {
  name = "${var.common-name}-1"
  region = "${var.gcp-region}"


  # min_master_version = "1.11.5"

  remove_default_node_pool = true
  
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }

}

resource "google_container_node_pool" "gke-dev-pool" {
  name = "default"
  location = "${var.gcp-region}"
  cluster = "${google_container_cluster.gke-dev.name}"

  initial_node_count = 1

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n1-standard-1"

    # https://www.terraform.io/docs/providers/google/r/container_cluster.html#oauth_scopes
    oauth_scopes = [
      "compute-rw",
      "storage-rw",
      "logging-write",
      "monitoring",
    ]

    labels = {
      owner  = "ankur_saxena"
      minion = "terraform"
    }
  }

# setup scripts
 provisioner "local-exec" {
   command = "bash gke-dev/setup-gke-dev"
 }

}
