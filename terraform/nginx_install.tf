# Reverse proxy
resource "null_resource" "nginx" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/nginx_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

#resource "null_resource" "nginx_ssh" {
 # provisioner "local-exec" {
  #  command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_ssh.yml --extra-vars 'username=${var.username} destfile=files/id_rsa.pub srcfile=files/id_rsa.pub'"
  #}

  #depends_on = [
   # null_resource.proxy
  #]
#}
