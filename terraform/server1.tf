# Network Interface for Server1
resource "azurerm_network_interface" "ad-cloudlab-vm-server1-nic" {
  name                 = "ad-cloudlab-vm-server1-nic"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ad-cloudlab-vm-server1-config"
    subnet_id                     = azurerm_subnet.ad-cloudlab-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.19"
  }
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "ad-cloudlab-vm-server1" {
  depends_on = [
    azurerm_network_interface.ad-cloudlab-vm-server1-nic,
    azurerm_nat_gateway.ad-cloudlab-nat-gateway,
    azurerm_windows_virtual_machine.ad-cloudlab-vm-dc
  ]
  name                     = "ad-cloudlab-vm-server1"
  computer_name            = var.server-hostname
  size                     = var.server-size
  provision_vm_agent       = true
  enable_automatic_updates = true
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  timezone                 = var.timezone
  admin_username           = var.windows-admin
  admin_password           = var.windows-admin-password
  network_interface_ids    = [
    azurerm_network_interface.ad-cloudlab-vm-server1-nic.id,
  ]

  os_disk {
    name                 = "ad-cloudlab-vm-server1-osdisk"
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
    content =  local.auto_logon_data
  }

  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = "${file("${path.module}/scripts/FirstLogonCommands.xml")}"
  } 
}

resource "azurerm_virtual_machine_extension" "winrm-extension-server1" {
    name                    = "vmext"
    virtual_machine_id = azurerm_windows_virtual_machine.ad-cloudlab-vm-server1.id
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
      azurerm_windows_virtual_machine.ad-cloudlab-vm-server1,
      azurerm_nat_gateway.ad-cloudlab-nat-gateway
    ]
}


