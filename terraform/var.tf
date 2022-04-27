variable "resource_group" {
  description = "Resource group in which resources should be created. Will automatically be created and should not exist prior to running Terraform"
  default     = "ad-cloud-lab"
}

variable "dc-hostname" {
  type = string
  description = "The hostname of the Windows Server 2016 DC VM."
  default = "dc"
}

variable "server-hostname" {
  type = string
  description = "The hostname of the Windows 10 VM."
  default = "server-2019"
}

variable "windows-admin" {
  type        = string
  description = "The local administrative username for Windows machines. Password will be generated."
  default     = "windowsadmin"
} 

variable "ip-whitelist" {
  description = "A list of CIDRs that will be allowed to access the exposed services."
  type        = list(string)
  default =  ["49.37.41.37"]
}

variable "domain-name-label" {
  description = "The DNS name of the Azure public IP."
  type        = string
  default     = "adlabforazure"
}

variable "domain-dns-name" {
  description = "The DNS name of the Active Directory domain."
  type        = string
  default     = "aurora.local"
}

variable "timezone" {
  type        = string
  description = "The timezone of the lab VMs."
  default     = "W. Europe Standard Time"
}

variable "jumpbox-hostname" {
  type = string
  description = "The hostname of the jumpbox VM."
  default = "jumpbox"
}

variable "linux-admin" {
  type        = string
  description = "The username used to access Linux machines via SSH."
  default     = "linuxadmin"
}

variable region{
  type = string
  description = "Azure location of terraform server environment"
  default = "australiaeast"
}

variable "dc-size" {
  type = string
  description = "The machine size of the Windows Server 2016 DC VM."
  default = "Standard_D2as_v4"
}

variable "server-size" {
  type = string
  description = "The machine size of the Windows 10 VM."
  default = "Standard_D2as_v4"
}

variable "jumpbox-size" {
  type = string
  description = "The machine size of the jumpbox VM."
  default = "Standard_D2as_v4"
}

variable "windows-admin-password"{
  type = string
  description = "The machine size of the jumpbox VM."
  default = "akevX:ZWnc6V8&-x"
}

