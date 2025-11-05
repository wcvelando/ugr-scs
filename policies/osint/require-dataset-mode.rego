package osint

deny[msg] {
  input.env == "student"
  not input.dataset_mode
  msg := "Scraper must run in dataset_mode in student environment"
}
