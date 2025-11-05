package main

# Config desde data.settings (inyectada con -d policies/config.json)
required_tags := {t | t := data.settings.required_tags[_]}
expected_owner := lower(data.settings.expected_owner)

# Recorremos todos los cambios del tfplan
deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null        # ignorar destroys / data sources sin "after"

  # Si el recurso no soporta tags (no hay "tags" o no es objeto), marcamos como faltantes todas
  not is_object(after.tags)
  msg := sprintf("Resource %s missing required tags (no tags object). Required: %v", [rc.address, array.concat(", ", data.settings.required_tags)])
}

# Faltantes específicas
deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  is_object(after.tags)

  some t
  required_tags[t]
  not after.tags[t]

  msg := sprintf("Resource %s missing required tag '%s'", [rc.address, t])
}

# Owner incorrecto (si existe owner pero no coincide con expected_owner)
deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  is_object(after.tags)
  after.tags.owner
  lower(sprintf("%v", after.tags.owner)) != expected_owner

  msg := sprintf("Resource %s has owner '%v' but expected '%s'", [rc.address, after.tags.owner, data.settings.expected_owner])
}
