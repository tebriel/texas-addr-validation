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
resource "azurerm_resource_group" "texas-addr-validation" {
  name     = "texas-addr-validation"
  location = "South Central US"
}
