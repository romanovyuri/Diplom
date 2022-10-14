#Устанавливаем все необходимые пакеты для Gitlab.
resource "null_resource" "gitlab" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}