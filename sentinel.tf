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

  incident_configuration {
    create_incident = true
    grouping {
      enabled                 = true
      reopen_closed_incidents = false
      lookback_duration       = "PT5M"
      entity_matching_method  = "AnyAlert"
    }
  }
}
