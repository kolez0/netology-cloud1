###cloud vars

variable "cloud_id" {
  type        = string
  default     = "b1g0bcbge4leskva6q64"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default = "b1gm8a6tiffresiiosuj"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-e"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "netology_vpc" {
  type        = string
  default     = "netology-vpc"
  description = "VPC name"
}

variable "netology_public_subnet" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "Public subnet CIDR"
}

variable "netology_private_subnet" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "Private subnet CIDR"
}

variable "vm_preemptible" {
  type        = bool
  default     = true
  description = "VM preemptible flag"
}

variable "vm_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "VM platform ID"
}

variable "vm_image_family" {
  type        = string
  default     = "ubuntu-2204-lts"
  description = "VM image family"
}

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
    nat           = bool
  }))
}

variable "vm_user" {
  description = "VM user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/yc_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "SSH private key path"
  type        = string
  default     = "~/.ssh/yc_ed25519"
}
