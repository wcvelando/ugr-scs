package main

required := {"env", "owner"}

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  tags := after.tags
  # si tags es null o no es objeto, falla
  not is_object(tags)
  msg := sprintf("Resource %s missing required tags (no tags object)", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  tags := after.tags
  is_object(tags)
  some k
  required[k]
  not tags[k]
  msg := sprintf("Resource %s missing required tag '%s'", [rc.address, k])
}
