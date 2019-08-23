## CONTAINS BLOCK VOLUMES FOR DB STORAGE ##

resource "aws_ebs_volume" "cassandra" {
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"
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