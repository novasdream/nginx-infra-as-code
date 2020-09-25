variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "teste_web_server"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "admin_username" {
  description = "The username from OS"
}

variable "admin_password" {
  description = "The password from OS"
}
