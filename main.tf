locals {
  default_tags = {
    env   = "lab"
    owner = var.owner
  }
}

locals {
  rg_name = coalesce(var.resource_group_name, "${var.prefix}-rg")
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = merge(local.default_tags, {})
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = merge(local.default_tags, {})
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.law.id
}

# Espera corta para consistencia eventual (delete/recreate)
resource "time_sleep" "wait_after_law" {
  create_duration = "45s"
  depends_on = [
    azurerm_log_analytics_workspace.law,
    azurerm_sentinel_log_analytics_workspace_onboarding.sentinel
  ]
}

data "azurerm_subscription" "current" {}

resource "azurerm_monitor_diagnostic_setting" "sub_activity_to_law" {
  name                       = "activity-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Ayuda a la resolución del destino en el provider
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "Administrative" }
  enabled_log { category = "Policy" }
  enabled_log { category = "Security" }
  enabled_log { category = "ServiceHealth" }
  enabled_log { category = "Alert" }
  enabled_metric { category = "AllMetrics" }

  # Esperar explícitamente a la onboarding + sleep
  depends_on = [time_sleep.wait_after_law]

  timeouts {
    create = "15m"
    read   = "5m"
  }
}
