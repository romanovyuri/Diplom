resource "yandex_compute_instance" "monitoring" {
  name        = "monitoring"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "monitoring.devopsrom"

  # В ресурсах 4 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 4
    memory = 4
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 20Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-ssd"
      size = "20"
    }
  }

  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]

    #Создать новый ресурс перед удалением старого
    # create_before_destroy = true
  }

  # Создаем сетевой интерфейс у ВМ, с адресом из ранее созданной подсети и NAT, чтобы был доступ из инета
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_zone_a_public.id
    nat = "false"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

