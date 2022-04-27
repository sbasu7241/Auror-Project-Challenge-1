resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.region
}

resource "azurerm_virtual_network" "ad-cloudlab-vnet" {
  name                = "ad-cloudlab-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ad-cloudlab-subnet" {
  name                 = "ad-cloudlab-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.ad-cloudlab-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create a network security group for the subnet
resource "azurerm_network_security_group" "ad-cloudlab-nsg" {
  name                = "ad-cloudlab-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }
 
  security_rule {
    name                       = "Internal"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ad-cloudlab-nsga" {
  subnet_id                 = azurerm_subnet.ad-cloudlab-subnet.id
  network_security_group_id = azurerm_network_security_group.ad-cloudlab-nsg.id
}

# Public IP for Load balancer
resource "azurerm_public_ip" "ad-cloudlab-ip" {
  name                = "ad-cloudlab-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"  
  domain_name_label   = var.domain-name-label
  sku                 = "Standard"
}

# Public IP for NAT gateway
resource "azurerm_public_ip" "ad-cloudlab-ip-nat" {
  name                = "ad-cloudlab-ip-nat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a load balancer on the public IP
resource "azurerm_lb" "ad-cloudlab-lb" {
  name                = "ad-cloudlab-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "ad-cloudlab-lb-ip-public"
    public_ip_address_id = azurerm_public_ip.ad-cloudlab-ip.id
  }
}

resource "azurerm_lb_nat_rule" "ad-cloudlab-lb-nat-http" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.ad-cloudlab-lb.id
  name                           = "HTTPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "ad-cloudlab-lb-ip-public"
}

resource "azurerm_lb_nat_rule" "ad-cloudlab-lb-nat-ssh" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.ad-cloudlab-lb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "ad-cloudlab-lb-ip-public"
}

resource "azurerm_lb_nat_rule" "ad-cloudlab-lb-nat-rdp" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.ad-cloudlab-lb.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "ad-cloudlab-lb-ip-public"
}

# Create NAT gateway for outbound internet access
resource "azurerm_nat_gateway" "ad-cloudlab-nat-gateway" {
  name                    = "ad-cloudlab-nat-gateway"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
}

# Associate public IP with nat gateway
resource "azurerm_nat_gateway_public_ip_association" "cloudlabs-nat-gateway-ip" {
  nat_gateway_id       = azurerm_nat_gateway.ad-cloudlab-nat-gateway.id
  public_ip_address_id = azurerm_public_ip.ad-cloudlab-ip-nat.id
}

# Associate subnet with nat gateway
resource "azurerm_subnet_nat_gateway_association" "cloudlabs-nat-gateway-subnet" {
  subnet_id      = azurerm_subnet.ad-cloudlab-subnet.id
  nat_gateway_id = azurerm_nat_gateway.ad-cloudlab-nat-gateway.id
}
