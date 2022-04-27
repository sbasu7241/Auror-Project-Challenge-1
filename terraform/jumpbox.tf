# Network Interface for Jumpbox
resource "azurerm_network_interface" "ad-cloudlab-vm-jumpbox-nic" {
  name                 = "ad-cloudlab-vm-jumpbox-nic"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ad-cloudlab-vm-jumpbox-config"
    subnet_id                     = azurerm_subnet.ad-cloudlab-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.10"
  }
}

# SSH nat rule association with Jumpbox
resource "azurerm_network_interface_nat_rule_association" "ad-cloudlab-vm-jumpbox-nic-nat" {
  network_interface_id  = azurerm_network_interface.ad-cloudlab-vm-jumpbox-nic.id
  ip_configuration_name = "ad-cloudlab-vm-jumpbox-config"
  nat_rule_id           = azurerm_lb_nat_rule.ad-cloudlab-lb-nat-ssh.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ad-cloudlab-vm-jumpbox" {
  depends_on = [
    azurerm_network_interface.ad-cloudlab-vm-jumpbox-nic,
    azurerm_windows_virtual_machine.ad-cloudlab-vm-dc,
    azurerm_windows_virtual_machine.ad-cloudlab-vm-server1
  ]
  name                = "ad-cloudlab-vm-jumpbox"
  computer_name       = var.jumpbox-hostname
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.jumpbox-size
  disable_password_authentication = false
  admin_username      = var.linux-admin
  admin_password      = random_string.linux_password.result
  network_interface_ids = [
    azurerm_network_interface.ad-cloudlab-vm-jumpbox-nic.id,
  ]

  os_disk {
    name                 = "ad-cloudlab-vm-jumpbox-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }  
}