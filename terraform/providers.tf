terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "diplomrom"
    region     = "ru-central1"
    key        = "diplomrom/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1gh7b7r0ukh1ac4te9o" # From yandex cloud
  folder_id = "b1gj0frieqjrcsrce4j3" # From yandex cloud
  zone      = "ru-central1-a"
}