resource "aws_ebs_volume" "cassandra" {
  availability_zone = "${var.region}a"
  size              = "${var.cassandra_disk_size}"
  count = "${var.cassandra_node_count}"
  type = "standard"

  tags = {
    Name = "${var.ec2_cassandra_instance_prefix}-${count.index}"
  }
}