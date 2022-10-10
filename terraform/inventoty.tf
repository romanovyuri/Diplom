resource "local_file" "inventory" {
  content = <<-DOC
    # Ansible inventory containing variable values from Terraform.
    # Generated by Terraform.

    [nodes:children]
    nginx
    nodesinside

    [nodesinside:children]
    mysql
    app
    gitlab
    runner
    monitoring

    [mysql:children]
    mysql1
    mysql2

    [nginx]
    ${yandex_compute_instance.nginx.hostname} ansible_host=${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}
    [mysql1]
    ${yandex_compute_instance.db01.hostname} ansible_host=${yandex_compute_instance.db01.network_interface.0.ip_address}
    [mysql2]
    ${yandex_compute_instance.db02.hostname} ansible_host=${yandex_compute_instance.db02.network_interface.0.ip_address}
    [app]
    ${yandex_compute_instance.app.hostname} ansible_host=${yandex_compute_instance.app.network_interface.0.ip_address}
    [gitlab]
    ${yandex_compute_instance.gitlab.hostname} ansible_host=${yandex_compute_instance.gitlab.network_interface.0.ip_address}
    [runner]
    ${yandex_compute_instance.runner.hostname} ansible_host=${yandex_compute_instance.runner.network_interface.0.ip_address}
    [monitoring]
    ${yandex_compute_instance.monitoring.hostname} ansible_host=${yandex_compute_instance.monitoring.network_interface.0.ip_address}
    [nodesinside:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ubuntu@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"'
 DOC
  filename = "../ansible/inventory"
  file_permission = "0644"
  depends_on = [
    yandex_compute_instance.nginx,
    yandex_compute_instance.db01,
    yandex_compute_instance.db02,
    yandex_compute_instance.gitlab,
    yandex_compute_instance.runner,
    yandex_compute_instance.monitoring,
    yandex_compute_instance.app,

  ]
}