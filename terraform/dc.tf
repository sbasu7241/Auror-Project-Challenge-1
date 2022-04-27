# Network Interface for DC
resource "azurerm_network_interface" "ad-cloudlab-vm-dc-nic" {
  name                 = "ad-cloudlab-vm-dc-nic"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ad-cloudlab-vm-dc-config"
    subnet_id                     = azurerm_subnet.ad-cloudlab-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.9"
  }
}

# # WinRM nat rule association with DC
# resource "azurerm_network_interface_nat_rule_association" "ad-cloudlab-vm-dc-nic-nat" {
#   network_interface_id  = azurerm_network_interface.ad-cloudlab-vm-dc-nic.id
#   ip_configuration_name = "ad-cloudlab-vm-dc-config"
#   nat_rule_id           = azurerm_lb_nat_rule.ad-cloudlab-lb-nat-winrm.id
# }

# Virtual Machine
resource "azurerm_windows_virtual_machine" "ad-cloudlab-vm-dc" {
  depends_on = [
    azurerm_network_interface.ad-cloudlab-vm-dc-nic,
    azurerm_nat_gateway.ad-cloudlab-nat-gateway
    ]
  name                     = "ad-cloudlab-vm-dc"
  computer_name            = var.dc-hostname
  size                     = var.dc-size
  provision_vm_agent       = true
  enable_automatic_updates = true
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  timezone                 = var.timezone
  admin_username           = var.windows-admin
  admin_password           = var.windows-admin-password
  #custom_data              = local.custom_data_content
  network_interface_ids    = [
    azurerm_network_interface.ad-cloudlab-vm-dc-nic.id,
  ]

  os_disk {
    name                 = "ad-cloudlab-vm-dc-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 
  additional_unattend_content {
    setting = "AutoLogon"
    content = local.auto_logon_data
  }

  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = local.first_logon_data
  } 
}

resource "azurerm_virtual_machine_extension" "winrm-extension-dc" {
    name                    = "vmext"
    virtual_machine_id = azurerm_windows_virtual_machine.ad-cloudlab-vm-dc.id
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"

    settings = <<SETTINGS
    {   
    "fileUris": [ "https://raw.githubusercontent.com/chvancooten/CloudLabsAD/main/Terraform/files/ConfigureRemotingForAnsible.ps1" ],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
    }
    SETTINGS

    depends_on = [
      azurerm_windows_virtual_machine.ad-cloudlab-vm-dc,
      azurerm_nat_gateway.ad-cloudlab-nat-gateway
    ]
}