resource "azurerm_key_vault" "texas" {
  name                            = "texas-key-vault"
  location                        = azurerm_resource_group.texas_addr_validation.location
  resource_group_name             = azurerm_resource_group.texas_addr_validation.name
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  tenant_id                       = "afdb9222-952a-462e-b5a0-86d1f274830c"
  soft_delete_enabled             = true
  purge_protection_enabled        = false

  sku_name = "standard"

  access_policy {
    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "ManageContacts",
      "ManageIssuers",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
    ]
    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
    object_id = "5fd8e33b-c116-44b7-b73d-b0c9b568d58b"
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
    storage_permissions = []
    tenant_id           = "afdb9222-952a-462e-b5a0-86d1f274830c"
  }

  access_policy {
    certificate_permissions = []
    key_permissions         = []
    object_id               = "1991f44a-c294-4d1a-85f9-a6b76ffcbc01"
    secret_permissions = [
      "get",
      "set",
      "delete",
    ]
    storage_permissions = []
    tenant_id           = "afdb9222-952a-462e-b5a0-86d1f274830c"
  }

  access_policy {
    certificate_permissions = []
    key_permissions         = []
    object_id               = "0b785ef6-aa6d-4d0f-bee7-7e399c8cfaaf"
    secret_permissions = [
      "get",
    ]
    storage_permissions = []
    tenant_id           = "afdb9222-952a-462e-b5a0-86d1f274830c"
  }


  network_acls {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  timeouts {

  }

  tags = {
    environment = "Testing"
  }
}
