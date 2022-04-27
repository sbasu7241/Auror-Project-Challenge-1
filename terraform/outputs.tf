output "region" {
  value = azurerm_resource_group.main.location
  description = "The region in which the resources are deployed. Based on the configured resource group."
}

output "public-ip" {
  value = azurerm_public_ip.ad-cloudlab-ip.ip_address
  description = "The public IP address used to connect to the lab."
}

output "public-ip-dns" {
  value = azurerm_public_ip.ad-cloudlab-ip.fqdn
  description = "The public DNS name used to connect to the lab."
}

output "public-ip-nat" {
    value = azurerm_public_ip.ad-cloudlab-ip-nat.ip_address
    description = "The public IP address used by the lab machines to reach the internet."
}

output "ip-whitelist" {
    value = join(", ", var.ip-whitelist)
    description = "The IP address(es) that are allowed to connect to the various lab interfaces."
}

output  "windows-domain" {
    value = var.domain-dns-name
    description = "The the Active Directory domain name."
}

output "dc-hostname" {
    value = var.dc-hostname
    description = "The hostname of the Domain Controller."
}

output "server-hostname" {
    value = var.server-hostname
    description = "The hostname of the Windows Server 2019 VM."
}

output "windows-user" {
    value = var.windows-admin
    description = "The username used to connect to the Windows machine."
}

output "linux-user" {
    value = var.linux-admin
    description = "The SSH username used to connect to Linux machines."
}

output "linux-password" {
    value = random_string.linux_password.result
    description = "The password used for Linux admin accounts."
}
