resource "null_resource" "local-execs" {
  provisioner "local-exec" {
    command = "echo \"Run this later : bash ./local-execs/init-vault\""
  }

  provisioner "local-exec" {
    command = "echo ${var.external_network_ip}"
  }
}
