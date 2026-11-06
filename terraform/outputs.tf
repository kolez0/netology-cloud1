output "nat_instance" {
  description = "NAT instance IP addresses"
  value = {
    internal_ip = yandex_compute_instance.nat_instance.network_interface[0].ip_address
    external_ip = yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address
  }
}

output "public_vm" {
  description = "Public VM IP addresses"
  value = {
    internal_ip = yandex_compute_instance.public_vm.network_interface[0].ip_address
    external_ip = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
  }
}

output "private_vm" {
  description = "Private VM IP address"
  value = {
    internal_ip = yandex_compute_instance.private_vm.network_interface[0].ip_address
  }
}

output "ssh_public_vm" {
  value = "ssh ${var.vm_user}@${yandex_compute_instance.public_vm.network_interface[0].nat_ip_address}"
}

output "ssh_private_vm_via_public" {
  value = "ssh -J ${var.vm_user}@${yandex_compute_instance.public_vm.network_interface[0].nat_ip_address} ${var.vm_user}@${yandex_compute_instance.private_vm.network_interface[0].ip_address}"
}