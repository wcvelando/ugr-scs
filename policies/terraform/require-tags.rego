package main

deny[msg] {
  rc := input.resource_changes[_]
  rc.change.after.tags == null
  msg := sprintf("Resource %s missing required tags", [rc.address])
}
