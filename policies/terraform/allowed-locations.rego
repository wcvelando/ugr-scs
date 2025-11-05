package main

allowed_locs := {"eastus", "westus2", "northeurope"}

deny[msg] {
  rc := input.resource_changes[_]
  loc := lower(rc.change.after.location)
  loc != ""
  not allowed_locs[loc]
  msg := sprintf("Location %s is not allowed for %s", [loc, rc.address])
}
