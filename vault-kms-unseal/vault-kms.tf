terraform {
  backend "gcs" {
    bucket  = "tf-admin-242820"
    prefix  = "terraform/state/vault-gcp-kms"
  }
}

provider "google" {
  credentials = file(var.account_file_path)
  project     = var.gcloud-project
  region      = var.gcloud-region
}

resource "google_service_account" "vault_kms_service_account" {
  account_id   = "vault-gcpkms"
  display_name = "Vault KMS for auto-unseal"
}

resource "google_compute_instance" "vault" {
  name         = "vault-test"
  machine_type = "n1-standard-1"
  zone         = var.gcloud-zone

  tags = ["${var.network}-${var.fwrulename}"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  # Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  allow_stopping_for_update = true

  # Service account with Cloud KMS roles for the Compute Instance
  service_account {
    email  = google_service_account.vault_kms_service_account.email
    scopes = ["cloud-platform", "compute-rw", "userinfo-email", "storage-ro"]
  }

  metadata_startup_script = <<SCRIPT
    sudo apt-get install -y unzip libtool libltdl-dev

    curl -s -L -o ~/vault.zip ${var.vault_url}
    sudo unzip ~/vault.zip
    sudo install -c -m 0755 vault /usr/bin

    sudo mkdir -p /test/vault

    sudo echo -e '[Unit]\nDescription="HashiCorp Vault - A tool for managing secrets"\nDocumentation=https://www.vaultproject.io/docs/\nRequires=network-online.target\nAfter=network-online.target\n\n[Service]\nExecStart=/usr/bin/vault server -config=/test/vault/config.hcl\nExecReload=/bin/kill -HUP $MAINPID\nKillMode=process\nKillSignal=SIGINT\nRestart=on-failure\nRestartSec=5\n\n[Install]\nWantedBy=multi-user.target\n' > /lib/systemd/system/vault.service

    sudo echo -e 'storage "file" {\n  path = "/opt/vault"\n}\n\nlistener "tcp" {\n  address     = "0.0.0.0:8200"\n  tls_disable = 1\n}\n\nseal "gcpckms" {\n  project     = "${var.gcloud-project}"\n  region      = "${var.keyring_location}"\n  key_ring    = "${var.key_ring}"\n  crypto_key  = "${var.crypto_key}"\n}\n\ndisable_mlock = true\n' > /test/vault/config.hcl

    sudo chmod 0664 /lib/systemd/system/vault.service

    sudo echo -e 'alias v="vault"\nalias vualt="vault"\nexport VAULT_ADDR="http://127.0.0.1:8200"\n' > /etc/profile.d/vault.sh

    source /etc/profile.d/vault.sh

    sudo systemctl enable vault
    sudo systemctl start vault
  
SCRIPT

 # setup scripts
#provisioner "local-exec" {
#  command = "bash setup-vault-dev -e '${self.network_interface.0.access_config.0.nat_ip}' -i '${self.network_interface.0.network_ip}'"
#}
}



# Create a KMS key ring
# resource "google_kms_key_ring" "key_ring" {
#   project  = "${var.gcloud-project}"
#   name     = "${var.key_ring}"
#   location = "${var.keyring_location}"
# }

# Create a crypto key for the key ring
# resource "google_kms_crypto_key" "crypto_key" {
#   name            = "${var.crypto_key}"
#   key_ring        = "${google_kms_key_ring.key_ring.self_link}"
#   rotation_period = "100000s"
# }

# Add the service account to the Keyring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  # key_ring_id = "${google_kms_key_ring.key_ring.id}"
  key_ring_id = "${var.gcloud-project}/${var.keyring_location}/${var.key_ring}"
  role = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.vault_kms_service_account.email}",
  ]
}

# Firewall rule to allow connecting to port
resource "google_compute_firewall" "fw-rule" {
  name      = "${var.network}-${var.fwrulename}"
  network   = "${var.network}"
  description = "Creates Firewall rule targetting tagged instances"

  allow {
    protocol = "${var.protocol}"
    ports    = "${var.ports}"
  }
  target_tags   = ["${var.network}-${var.fwrulename}"]
  source_ranges = "${var.source_ranges}"
}

#resource "null_resource" "delay" {
#  provisioner "local-exec" {
#    command = "sleep 10"
#  }
#  triggers = {
#    "after" = "${google_compute_instance.vault.id}"
#  }
#}

resource "null_resource" "post" {
  # setup scripts
  provisioner "local-exec" {
   command = "echo \"bash ./local-execs/setup-vault-dev -e '${google_compute_instance.vault.network_interface.0.access_config.0.nat_ip}' -i '${google_compute_instance.vault.network_interface.0.network_ip}'\" > ./local-execs/init-vault"
    
  }
  triggers = {
    "after" = "${google_compute_instance.vault.id}"
  }
  #depends_on = ["null_resource.delay"]
}