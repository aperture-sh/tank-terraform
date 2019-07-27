variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the VPC."
  default     = "10.0.2.0/24"
}

variable "public_subnet_cidr" {
  description = "The Public Subnet CIDR block for the VPC."
  default     = "10.0.3.0/24"
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

variable "aws_profile" {
  description = "Local aws profile to use for provisioning resoources"
  default = "default"
}

variable "gateway_instance_type" {
  default = "m5.xlarge"
}

variable "tank_instance_type" {
  default = "m5.xlarge"
}

variable "cassandra_instance_type" {
  default = "m5.xlarge"
}

variable "ami_id" {
  # Ubuntu 18.04 LTS - HVM-SSD
  default = "ami-090f10efc254eaf55"
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

variable "docker_username" {
  default = ""
}

variable "docker_password" {
  default = ""
}