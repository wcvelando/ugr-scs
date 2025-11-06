package main

# Detecta reglas NSG que permiten SSH (22) desde 0.0.0.0/0 en el tfplan.json
deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_network_security_rule"
  after := rc.change.after
  after != null

  # source_address_prefix puede venir en mayúsculas/minúsculas variadas
  lower(after.source_address_prefix) == "0.0.0.0/0"

  # destino puede venir numérico o string; castear con sprintf
  sprintf("%v", after.destination_port_range) == "22"

  msg := sprintf("NSG rule allows public ingress to port 22 (%s)", [rc.address])
}
