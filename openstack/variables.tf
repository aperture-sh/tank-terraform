variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "The Subnet CIDR block for the VPC."
  default     = "192.168.0.0/24"
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
  default = "eu-central-1"
}

variable "keypair" {
  description = "Keypair to use for EC2 Instances"
}

variable "keyfile" {
  description = "Private key to use for ssh auth"
  default = "~/.ssh/id_rsa"
}

variable "gateway_instance_type" {
  default = "4C-16GB"
}

variable "tank_instance_type" {
  default = "4C-16GB"
}

variable "cassandra_instance_type" {
  default = "4C-16GB"
}

variable "image_id" {
  # Ubuntu 18.04 LTS - HVM-SSD
  default = "e00b1a59-4e5b-4f2c-8bea-463970ad2dee"
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

variable "openstack_auth_url" {
  default = "https://cloudapi.igd.fraunhofer.de:5000/v3"
}

variable "openstack_project" {
  default = "Databio"
}

variable "openstack_username" {}
variable "openstack_password" {
  default = ""
}

variable "docker_username" {
  default = ""
}

variable "docker_password" {
  default = ""
}