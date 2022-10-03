resource "local_file" "inventory" {
  content = <<-DOC
    # Ansible inventory containing variable values from Terraform.
    # Generated by Terraform.

    [nodes:children]
    nginx



    [nginx]
    nginx.netology.yc ansible_host=${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}


    DOC
  filename = "../ansible/inventory"
  file_permission = "0644"
  depends_on = [
    yandex_compute_instance.nginx,

  ]
}
