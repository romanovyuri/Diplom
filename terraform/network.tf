# Создаем сеть
resource "yandex_vpc_network" "default" {
  name = "net"
}

# Создаем подсеть в зоне A для Public
resource "yandex_vpc_subnet" "subnet_zone_a_public" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.10.0/24"]

}
#Маршрут из зоны А на proxy, там NAT
resource "yandex_vpc_route_table" "route_table_nat" {
  description = "Route table for inside subnets"
  name        = "route_table_nat"

  depends_on = [
    yandex_compute_instance.nginx
  ]

  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nginx.network_interface.0.ip_address
  }
}

#Создаем подсеть в зоне A для Private
resource "yandex_vpc_subnet" "subnet_zone_a_private" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  route_table_id = yandex_vpc_route_table.route_table_nat.id
  }

/*# Создаем подсеть в зоне B для Public
resource "yandex_vpc_subnet" "subnet_zone_b_public" {
  zone       = "ru-central1-b"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

# Создаем подсеть в зоне B для Private
resource "yandex_vpc_subnet" "subnet_zone_b_private" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.21.0/24"]
}*/

# Создается запись в зоне для домена, после создания NGINX
data "yandex_dns_zone" "zone" {
  name = "devops-netology"
}
resource "yandex_dns_recordset" "rs" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "devopsrom.ru."
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "www"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "gitlab"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "rs3" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "grafana"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "rs4" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "alertmanager"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "rs5" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "prometheus"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}