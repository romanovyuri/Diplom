#Установка и настройка сервера NGINX как Reverse Proxy
resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.inventory
  ]
}
#Устанавливаем все необходимые пакеты для NGINX. Устанавливаем сам пакет NGINX.
resource "null_resource" "nginx" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

# Генерируем ssh ключи на NGINX, копируем их на внутренние ресурсы "nodesinside" для доступа по SSH.
resource "null_resource" "ssh_tools" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/ssh_tools.yml --extra-vars 'username=ubuntu destfile=files/id_rsa.pub srcfile=files/id_rsa.pub'"
  }

  depends_on = [
    null_resource.nginx
  ]
}


# Создание TLS сертификатов, используя letsencrypt. Создаем сертификат для корневого домена.
resource "null_resource" "get_letsencrypt" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=devopsrom.ru'"
  }

  depends_on = [
    null_resource.ssh_tools
  ]
}

# Создание TLS сертификатов, используя letsencrypt. Создаем сертификаты для всех поддоменов
resource "null_resource" "get_letsencrypt_service_www" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=www.devopsrom.ru'"
  }
  depends_on = [
    null_resource.get_letsencrypt
  ]
}
resource "null_resource" "get_letsencrypt_service_gitlab" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=gitlab.devopsrom.ru'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_www
  ]
}
resource "null_resource" "get_letsencrypt_service_grafana" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=grafana.devopsrom.ru'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_gitlab
  ]
}
resource "null_resource" "get_letsencrypt_service_prometheus" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=prometheus.devopsrom.ru'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_grafana
  ]
}
resource "null_resource" "get_letsencrypt_service_alertmanager" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=alertmanager.devopsrom.ru'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_prometheus
  ]
}
#Создание конфигурации NGINX для корневого домена и поддоменов с работой сертификатов TLS.
resource "null_resource" "nginx_config" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=app:8080 default_conf_file=default.conf'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
resource "null_resource" "nginx_config_www" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=www.devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=app:8080'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
resource "null_resource" "nginx_config_gitlab" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=gitlab.devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=gitlab'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
resource "null_resource" "nginx_config_grafana" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=grafana.devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=monitoring:3000'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
resource "null_resource" "nginx_config_prometheus" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=prometheus.devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=monitoring:9090'"
  }
  depends_on = [
    null_resource.get_letsencrypt
  ]
}
resource "null_resource" "nginx_config_alertmanager" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_config.yml --extra-vars 'domain_name=alertmanager.devopsrom.ru conf_dir=/etc/nginx/conf.d service_ip_port=monitoring:9093'"
  }
  depends_on = [
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
# Рестарт nginx для применения созданных конфигов
resource "null_resource" "nginx_restart" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_restart.yml"
  }

  depends_on = [
    null_resource.nginx_config,
    null_resource.nginx_config_www,
    null_resource.nginx_config_gitlab,
    null_resource.nginx_config_grafana,
    null_resource.nginx_config_prometheus,
    null_resource.nginx_config_alertmanager,
    null_resource.get_letsencrypt_service_alertmanager
  ]
}
