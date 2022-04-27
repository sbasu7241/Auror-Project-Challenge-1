locals {
    first_logon_data     = file("${path.module}/scripts/FirstLogonCommands.xml")
    auto_logon_data      = file("${path.module}/scripts/autologon.xml")
}

