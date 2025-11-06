package main

# Config desde data.settings (inyectada con -d policies/config.json)
required_tags_set := {t | t := data.settings.required_tags[_]}
expected_owner := lower(data.settings.expected_owner)

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null

  not is_object(after.tags)

  required_list := data.settings.required_tags
  msg := sprintf("Resource %s missing required tags (no tags object). Required: %s", [rc.address, concat(", ", required_list)])
}

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  is_object(after.tags)

  some t
  required_tags_set[t]
  not after.tags[t]

  msg := sprintf("Resource %s missing required tag '%s'", [rc.address, t])
}

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after != null
  is_object(after.tags)
  after.tags.owner
  lower(sprintf("%v", after.tags.owner)) != expected_owner

  msg := sprintf("Resource %s has owner '%v' but expected '%s'", [rc.address, after.tags.owner, data.settings.expected_owner])
}
