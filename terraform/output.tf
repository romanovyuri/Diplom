
output "external_ip_address_ngnix" {
  value = yandex_compute_instance.nginx.network_interface[0].nat_ip_address
}

output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface[0].ip_address
}
