package main

deny[msg] {
  input.resource_changes[_].type == "azurerm_network_security_rule"
  rule := input.resource_changes[_]
  addr := rule.change.after.source_address_prefix
  port := tostring(rule.change.after.destination_port_range)
  lower(addr) == "0.0.0.0/0"
  port == "22"
  msg := sprintf("NSG rule allows public ingress to port %s", [port])
}
