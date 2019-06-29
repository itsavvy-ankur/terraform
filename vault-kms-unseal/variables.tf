variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.1.2/vault_1.1.2_linux_amd64.zip"
}

variable "gcloud-project" {
  description = "Google project name"
  default = "tf-admin-242820"
}

variable "gcloud-region" {
  default = "europe-west2"
}

variable "gcloud-zone" {
  default = "europe-west2-a"
}

variable "account_file_path" {
  description = "Path to GCP account file"
  default = "/home/iamtheone_ankur/.config/gcloud/iamtheone_ankur-terraform-admin.json"
}

variable "key_ring" {
  description = "Cloud KMS key ring name to create"
  default     = "test"
}

variable "crypto_key" {
  default     = "vault-test"
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  default = "global"
}

variable "fwrulename" {
  description = "Name of the Firewall rule"
  default = "vault"
}

variable "network" {
  description = "The name or self_link of the network to attach this firewall to"
  default = "default"
}

variable "source_ranges" {
  type = "list"
  description = "A list of source CIDR ranges that this firewall applies to. Can't be used for EGRESS"
  default = ["0.0.0.0/0"]
}

variable "target_tags" {
  type = "list"
  description = "A list of target tags for this firewall"
  default = [""]
}

variable "protocol" {
  description = "The name of the protocol to allow. This value can either be one of the following well known protocol strings (tcp, udp, icmp, esp, ah, sctp), or the IP protocol number, or all"
  default = "tcp"
}

variable "ports" {
  type = "list"
  description = "List of ports and/or port ranges to allow. This can only be specified if the protocol is TCP or UDP"
  default = ["8200"]
}
