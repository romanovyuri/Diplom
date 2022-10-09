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
# Создание TLS сертификатов, используя letsencrypt. Создаем сертификат для корневого домена.
resource "null_resource" "get_letsencrypt" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=devopsrom.ru'"
  }

  depends_on = [
    #null_resource.proxy_insert_dnat_rule,
    local_file.inventory,
    yandex_dns_recordset.rs
  ]
}

# Создание TLS сертификатов, используя letsencrypt. Создаем сертификат для www
resource "null_resource" "get_letsencrypt_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=www.devopsrom.ru'"
  }

  depends_on = [
    #null_resource.proxy_insert_dnat_rule,
    local_file.inventory,
    yandex_dns_recordset.rs1
  ]
}