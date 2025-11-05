package osint

deny[msg] {
  input.fetch_targets[_] == url
  endswith(lower(url), ".onion")
  msg := sprintf("Target not allowed in student env: %s", [url])
}
