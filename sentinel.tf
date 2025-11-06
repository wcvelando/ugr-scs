resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.law.id
  customer_managed_key_enabled = false
}

resource "azurerm_sentinel_alert_rule_scheduled" "delete_ops" {
  name                       = "Detect-Resource-Delete"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "[UGR] Azure Resource Delete Detected"
  severity                   = "High"
  query_frequency            = "PT15M"
  query_period               = "PT30M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  enabled                    = true

  query = <<KQL
AzureActivity
| where TimeGenerated >= ago(30m)
| where OperationNameValue has "delete"
| project TimeGenerated, OperationNameValue, ResourceGroup, Caller, ActivityStatusValue, CategoryValue
KQL

  # 👇 fuerza orden correcto
  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.sentinel
  ]
}
