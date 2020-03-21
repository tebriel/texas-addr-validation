resource "azurerm_app_service_plan" "texas" {
  name                = "ASP-texasaddrvalidation-b197"
  location            = azurerm_resource_group.texas_addr_validation.location
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  is_xenon            = false
  kind                = "linux"
  per_site_scaling    = false
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_app_service" "texas" {
  name                = "texas-addr-validation"
  location            = azurerm_resource_group.texas_addr_validation.location
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  app_service_plan_id = azurerm_app_service_plan.texas.id
  https_only          = true

  site_config {
    always_on                = true
    linux_fx_version         = "DOCKER|cmoultrie/texas-addr-validation:latest"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = ""
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = ""
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}

resource "azurerm_app_service_certificate" "validator" {
  name                = "texas-validator-texas-addr-validation-SouthCentralUSwebspace"
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  location            = azurerm_resource_group.texas_addr_validation.location
}

resource "azurerm_app_service_custom_hostname_binding" "validator" {
  hostname            = "validator.texas.frodux.in"
  app_service_name    = azurerm_app_service.texas.name
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  ssl_state           = "SniEnabled"
  thumbprint          = azurerm_app_service_certificate.validator.thumbprint
}

resource "azurerm_app_service_slot" "flask" {
  name                = "flask-validator"
  app_service_name    = azurerm_app_service.texas.name
  location            = azurerm_resource_group.texas_addr_validation.location
  resource_group_name = azurerm_resource_group.texas_addr_validation.name
  app_service_plan_id = azurerm_app_service_plan.texas.id

  site_config {
    always_on                = true
    linux_fx_version         = "DOCKER|cmoultrie/texas-addr-validation:latest"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = ""
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = ""
    "UPS_LICENSE_NUMBER"                  = var.ups_license_number
    "UPS_USERNAME"                        = var.ups_username
    "UPS_PASSWORD"                        = var.ups_password
    "HANDSHAKE_KEY"                       = var.handshake_key
    "HMAC_KEY"                            = var.hmac_key
  }
}

resource "azurerm_app_service_active_slot" "example" {
  resource_group_name   = azurerm_resource_group.texas_addr_validation.name
  app_service_name      = azurerm_app_service.texas.name
  app_service_slot_name = azurerm_app_service_slot.flask.name
}
