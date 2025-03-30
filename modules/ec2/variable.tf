variable "key_pair_name" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "ExampleAppServerInstance"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "has_public_ip" {
  type    = bool
  default = false
}
