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
  # record              = azurerm_container_group.flask.fqdn
  record = azurerm_app_service.texas.default_site_hostname
}
