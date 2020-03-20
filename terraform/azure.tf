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

resource "azurerm_storage_account" "texas" {
  name                     = "functionsapptestsa"
  resource_group_name      = "azurerm_resource_group.texas_addr_validation.name"
  location                 = "azurerm_resource_group.texas_addr_validation.location"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "texas" {
  name                = "azure-functions-texas-service-plan"
  location            = "azurerm_resource_group.texas_addr_validation.location"
  resource_group_name = "azurerm_resource_group.texas_addr_validation.name"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "validator" {
  name                      = "validator"
  location                  = azurerm_resource_group.texas_addr_validation.location
  resource_group_name       = azurerm_resource_group.texas_addr_validation.name
  app_service_plan_id       = azurerm_app_service_plan.texas.id
  storage_connection_string = azurerm_storage_account.texas.primary_connection_string
}
