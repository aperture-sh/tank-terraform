variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The Subnet CIDR block for the VPC."
  default     = "10.0.2.0/24"
}

variable "ec2_tank_instance_prefix" {
  description = "Name prefix for ec2 instances"
  default = "tank"
}

variable "ec2_cassandra_instance_prefix" {
  description = "Name prefix for ec2 instances"
  default = "cassandra"
}
variable "region" {
  default = "northeurope"
}

variable "gateway_instance_type" {
  default = "Standard_DS1_v2"
}

variable "tank_instance_type" {
  default = "Standard_DS1_v2"
}

variable "cassandra_instance_type" {
  default = "Standard_DS1_v2"
}

variable "tank_node_count" {
  default = "3"
}

variable "cassandra_node_count" {
  default = "3"
}

variable "number_of_cassandra_seeds" {
  default = "2"
}

variable "tank_disk_size" {
  default = "10"
}

variable "cassandra_disk_size" {
  default = "10"
}

variable "vm_username" {
  default = ""
}

variable "keyfile" {
  description = "Private key to use for ssh auth"
  default = "~/.ssh/id_rsa"
}

variable "docker_username" {
  default = ""
}

variable "docker_password" {
  default = ""
}

variable "mapbox_key" {
  default = ""
}