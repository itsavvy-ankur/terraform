output "external_network_ip" {
  value = "${google_compute_instance.vault.network_interface.0.access_config.0.nat_ip}"
}

output "internal_network_ip" {
  value = "${google_compute_instance.vault.network_interface.0.network_ip}"
}

output "project" {
  value = google_compute_instance.vault.project
}

output "vault_server_instance_id" {
  value = google_compute_instance.vault.self_link
}