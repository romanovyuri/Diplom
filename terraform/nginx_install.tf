resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "nginx" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

# Генерируем ssh ключи на NGINX, забираем открытый ключ в files/id_rsa.pub. Копируем открытый ключ на ноды внутри, чтобы к ним был доступ с сервера NGINX.
# Внутренние ноды не имеют внешних адресов. Заходить будем через сервер NGINX, используя ssh proxy.
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
    null_resource.nginx
  ]
}

# Создание TLS сертификатов, используя letsencrypt. Создаем сертификат для www
resource "null_resource" "get_letsencrypt_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=www.devopsrom.ru'"
  }

  depends_on = [
    null_resource.nginx
  ]
}