# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
resource "yandex_compute_instance" "nginx" {
  name        = "nginx"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "nginx.devopsrom.ru"

  # В ресурсах 2 ядра, 2 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = "fd8v7ru46kt3s4o5f0uo"
      type = "network-hdd"
      size = "20"
    }
  }


  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]

    #Создать новый ресурс перед удалением старого
    # create_before_destroy = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_zone_a_public.id
    nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}