resource "null_resource" "ansible-provisioning-jumpbox" {
    depends_on = [
      azurerm_nat_gateway.ad-cloudlab-nat-gateway
    ]    
    triggers = {
    always_run = "${timestamp()}"
  }
  connection {
    type  = "ssh"
    host  = azurerm_public_ip.ad-cloudlab-ip.ip_address
    user  = var.linux-admin
    password = random_string.linux_password.result
  }
  
  #Copy folder to jumpbox
  provisioner "file" {
    source      = "../ansible"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt -qq update >/dev/null",
      "sudo apt -qq install -y git ansible sshpass >/dev/null",
      "ansible-galaxy collection install ansible.windows community.general chocolatey.chocolatey >/dev/null",
      "cd /tmp/ansible",
      "ansible-playbook -v ad-cloudlab.yml"
    ]
  }
}