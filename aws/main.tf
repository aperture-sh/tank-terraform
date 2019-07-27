provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.region}"
}

resource "aws_vpc" "tank_vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "Tank VPC"
  }
}

# Define the public subnet
resource "aws_subnet" "tank_private_subnet" {
  vpc_id = "${aws_vpc.tank_vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Tank Private Subnet"
  }
}

# Define the public subnet
resource "aws_subnet" "tank_public_subnet" {
  vpc_id = "${aws_vpc.tank_vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Tank Public Subnet"
  }
}

resource "aws_eip" "nat" {
  depends_on = ["aws_internet_gateway.tank_gateway"]
  vpc      = true

  tags = {
    Name = "Tank NAT EIP"
  }
}

resource "aws_nat_gateway" "tank_gateway" {
  subnet_id = "${aws_subnet.tank_public_subnet.id}"
  allocation_id = "${aws_eip.nat.id}"

  tags = {
    Name = "Tank VPC IGW"
  }
}

resource "aws_internet_gateway" "tank_gateway" {
  vpc_id = "${aws_vpc.tank_vpc.id}"

  tags = {
    Name = "Tank VPC IGW"
  }
}

resource "aws_route_table" "tank_private_rt" {
  vpc_id = "${aws_vpc.tank_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.tank_gateway.id}"
  }

  tags = {
    Name = "Private Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "tank_private_rt" {
  subnet_id = "${aws_subnet.tank_private_subnet.id}"
  route_table_id = "${aws_route_table.tank_private_rt.id}"
}

resource "aws_route_table" "tank_public_rt" {
  vpc_id = "${aws_vpc.tank_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tank_gateway.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "tank_public_rt" {
  subnet_id = "${aws_subnet.tank_public_subnet.id}"
  route_table_id = "${aws_route_table.tank_public_rt.id}"
}

resource "aws_security_group" "http" {
  name        = "tank-http"
  description = "Allow inbound HTTP traffic"
  vpc_id      = "${aws_vpc.tank_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tank-http"
  }
}

resource "aws_security_group" "ssh" {
  name        = "tank-ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = "${aws_vpc.tank_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tank-ssh"
  }
}

resource "aws_ebs_volume" "cassandra" {
  availability_zone = "${var.region}a"
  size              = "${var.cassandra_disk_size}"
  count = "${var.cassandra_node_count}"
  type = "standard"

  tags = {
    Name = "${var.ec2_cassandra_instance_prefix}-${count.index}"
  }
}

resource "aws_volume_attachment" "cassandra" {
  device_name = "/dev/xvdf"
  count = "${var.cassandra_node_count}"
  volume_id   = "${element(aws_ebs_volume.cassandra.*.id, count.index)}"
  instance_id = "${element(aws_instance.cassandra.*.id, count.index)}"
  force_detach = true
}

resource "aws_instance" "gateway" {
  ami           = "${var.ami_id}"
  instance_type = "${var.gateway_instance_type}"
  key_name = "${var.keypair}"
  tags = {
    Name = "tank-gateway"
  }
  
  root_block_device {
    volume_type = "standard"
    volume_size = 50
    delete_on_termination = true
  }

  ephemeral_block_device {
    no_device = true
    device_name = "/dev/sda"
  }

  vpc_security_group_ids = [ "${aws_security_group.http.id}", "${aws_security_group.ssh.id}" ]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.tank_public_subnet.id}"
}

resource "aws_instance" "tank" {
  ami           = "${var.ami_id}"
  instance_type = "${var.tank_instance_type}"
  count = "${var.tank_node_count}"
  key_name = "${var.keypair}"
  tags = {
    Name = "${var.ec2_tank_instance_prefix}-${count.index}"
  }

  root_block_device {
    volume_type = "standard"
    volume_size = "${var.tank_disk_size}"
    delete_on_termination = true
  }

  ephemeral_block_device {
    no_device = true
    device_name = "/dev/sda"
  }

  vpc_security_group_ids = [ "${aws_security_group.ssh.id}" ]
  associate_public_ip_address = false
  subnet_id = "${aws_subnet.tank_private_subnet.id}"
}

resource "aws_instance" "cassandra" {
  ami           = "${var.ami_id}"
  instance_type = "${var.cassandra_instance_type}"
  count = "${var.cassandra_node_count}"
  key_name = "${var.keypair}"
  tags = {
    Name = "${var.ec2_cassandra_instance_prefix}-${count.index}"
  }
  # user_data = "${file("files/attach_ebs.sh")}"
  
  vpc_security_group_ids = [ "${aws_security_group.ssh.id}" ]
  associate_public_ip_address = false
  subnet_id = "${aws_subnet.tank_private_subnet.id}"
}
