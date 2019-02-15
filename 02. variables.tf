variable "azone" {
  default = "ru-central1-с"
}

variable "project_name_prefix" {
  type = "string"
  default = "tfdpl"
}

variable "master_name_prefix" {
  type = "string"
  default = "master"
}

variable "master_count" {
  default = 1
}

variable "master_cpu_count" {
  default = 32
}

variable "worker_name_prefix" {
  type = "string"
  default = "node"
}

variable "worker_count" {
  default = 15
}

variable "worker_cpu_count" {
  default = 32
}

variable "worker_disk_size" {
  default = 200
}

variable "master_scripts_list" {
  type = "list"
  default = [
    "scripts/master.sh"
  ]
}

variable "worker_scripts_list" {
  type = "list"
  default = [
    "scripts/worker.sh"
  ]
}

variable "output_path" {
  type = "string"
  default = "output/"
}

variable "private_key_file" {
  type = "string"
  default = "output/key.pem"
}

variable "username" {
  type = "string"
  default = "user"
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