# Настройка  MySQL
# Устанавливаем все необходимые пакеты для MySQL. Устанавливаем сам пакет MySQL.
resource "null_resource" "monitoring_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/monitoring_install.yml"
  }
  depends_on = [
    null_resource.nginx_restart,
    null_resource.app,
    null_resource.gitlab,
    null_resource.mysql_install
  ]
}
