# Configure the Azure Provider
provider "azurerm" {
  version = "=2.2.0"
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "tebrielterraformstate"
    container_name       = "texas-addr-validation"
    key                  = "terraform.tfstate"
  }
}

# Create a resource group
resource "azurerm_resource_group" texas_addr_validation {
  name     = "texas-addr-validation"
  location = "South Central US"
}

resource "azurerm_dns_zone" "texas" {
  name                = "texas.frodux.in"
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
}

resource "azurerm_dns_cname_record" "validator" {
  name                = "validator"
  zone_name           = azurerm_dns_zone.texas.name
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  ttl                 = 60
  record              = azurerm_container_group.flask.fqdn
}

resource "azurerm_container_group" "flask" {
  name                = "flask-container"
  location            = azurerm_resource_group.texas_addr_validation.location
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  ip_address_type     = "public"
  dns_name_label      = "texas-addr-validation"
  os_type             = "Linux"

  container {
    name   = "flask"
    image  = "cmoultrie/texas-addr-validation:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }
    secure_environment_variables = {
      UPS_LICENSE_NUMBER: var.ups_license_number,
      UPS_USERNAME: var.ups_username,
      UPS_PASSWORD: var.ups_password,
      HANDSHAKE_KEY: var.handshake_key,
      HMAC_KEY: var.hmac_key,
    }
  }

  tags = {
    environment = "testing"
  }
}
