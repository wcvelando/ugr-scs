resource "time_sleep" "after_onboard" {
  depends_on      = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
  create_duration = "120s"
}

resource "azurerm_sentinel_alert_rule_scheduled" "delete_ops" {
  name                       = "Detect-Resource-Delete"
  display_name               = "[UGR] Azure Resource Delete Detected"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  severity        = "High"
  query_period    = "PT30M" # ventana de datos
  query_frequency = "PT15M" # frecuencia de evaluación

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  enabled              = true
  suppression_enabled  = false
  suppression_duration = "PT5H"

  query = <<KQL
AzureActivity
| where TimeGenerated >= ago(30m)
| where OperationNameValue has "delete"
| project TimeGenerated, OperationNameValue, ResourceGroup, Caller, ActivityStatusValue, CategoryValue
KQL

  # Garantiza el orden: onboarding -> espera -> regla
  depends_on = [
    time_sleep.after_onboard
  ]
}