resource "random_string" "linux_password" {
  length           = 16
  special          = true
  min_upper        = 1
  min_numeric      = 1
}