variable "azone" {
  type = "string"
  default = "ru-central1-a"
}

variable "nat_instance_name" {
  type = "string"
  default = "nat-gateway"
}

variable "nat_instance_cpu_count" {
  default = 2
}

variable "nat_instance_ram_size" {
  default = 8
}

variable "nat_instance_disk_size" {
  default = 15
}

variable "nat_instance_script" {
  type = "list"
  default = [
    "scripts/nat.sh"
  ]
}

variable "private_key_file" {
  type = "string"
  default = "key.pem"
}

variable "username" {
  type = "string"
  default = "yc-user"
}

variable "token" {
  type = "string"
}

variable "cloud_id" {
  type = "string"
}

variable "folder_id" {
  type = "string"
}