resource "yandex_compute_instance" "runner" {
  name        = "runner"
  allow_stopping_for_update = true
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "runner.devopsrom"

  # В ресурсах 2 ядра, 2 гига оперативы, под 100% нагрузку
  resources {
    cores  = 4
    memory = 4
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
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
    nat = "false"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}