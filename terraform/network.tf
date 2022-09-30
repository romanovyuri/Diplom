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

#Создаем подсеть в зоне A для Private
resource "yandex_vpc_subnet" "subnet_zone_a_private" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  }

# Создаем подсеть в зоне B для Public
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
}
