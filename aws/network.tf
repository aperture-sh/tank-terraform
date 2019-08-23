## CONTAINS NETWORK RESOURCES SUCH AS VPC, GATEWAYS, ELASTIC_IP, SECURITY_GROUPS ##

resource "aws_vpc" "tank_vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "Tank VPC"
  }
}

resource "aws_subnet" "tank_private_subnet" {
  vpc_id = "${aws_vpc.tank_vpc.id}"
  count = 2
  cidr_block = "${var.private_subnet_cidr[count.index]}"
  availability_zone = "${var.region}${ count.index == 0 ? "a" : "b" }"

  tags = {
    Name = "Tank Private Subnet"
  }
}

resource "aws_subnet" "tank_public_subnet" {
  vpc_id = "${aws_vpc.tank_vpc.id}"
  count = 2
  cidr_block = "${var.public_subnet_cidr[count.index]}"
  availability_zone = "${var.region}${ count.index == 0 ? "a" : "b" }"

  tags = {
    Name = "Tank Public Subnet"
  }
}

resource "aws_eip" "nat" {
  depends_on = ["aws_internet_gateway.tank_gateway"]
  count = 2
  vpc      = true

  tags = {
    Name = "Tank NAT EIP"
  }
}

resource "aws_nat_gateway" "tank_gateway" {
  subnet_id = "${element(aws_subnet.tank_public_subnet.*.id, count.index)}"
  count = 2
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"

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
  count = 2

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.tank_gateway.*.id, count.index)}"
  }

  tags = {
    Name = "Private Subnet RT"
  }
}

resource "aws_route_table_association" "tank_private_rt" {
  count = 2
  subnet_id = "${element(aws_subnet.tank_private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.tank_private_rt.*.id, count.index)}"
}

resource "aws_route_table" "tank_public_rt" {
  vpc_id = "${aws_vpc.tank_vpc.id}"
  count = 2

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tank_gateway.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table_association" "tank_public_rt" {
  count = 2
  subnet_id = "${element(aws_subnet.tank_public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.tank_public_rt.*.id, count.index)}"
}

resource "aws_lb" "tank_alb" {
  name               = "tank-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.http.id}"]
  subnets            = "${aws_subnet.tank_public_subnet.*.id}"

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "tank" {
  load_balancer_arn = "${aws_lb.tank_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tank.arn}"
  }
}

resource "aws_lb_target_group" "tank" {
  name     = "tank-lb-tg"
  port     = 8888
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tank_vpc.id}"
}

resource "aws_lb_target_group" "navigator" {
  name     = "navigator-lb-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tank_vpc.id}"
}

resource "aws_lb_target_group" "exhauster" {
  name     = "exhauster-lb-tg"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tank_vpc.id}"
}

resource "aws_lb_target_group" "grafana" {
  name     = "grafana-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tank_vpc.id}"
}

resource "aws_lb_listener_rule" "navigator" {
  listener_arn = "${aws_lb_listener.tank.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.navigator.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/navigator*"]
  }
}

resource "aws_lb_listener_rule" "tank" {
  listener_arn = "${aws_lb_listener.tank.arn}"
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tank.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/tank*"]
  }
}

resource "aws_lb_listener_rule" "exhauster" {
  listener_arn = "${aws_lb_listener.tank.arn}"
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.exhauster.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/exhauster*"]
  }
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = "${aws_lb_listener.tank.arn}"
  priority     = 103

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.grafana.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/grafana*"]
  }
}

resource "aws_lb_target_group_attachment" "tank" {
  count = "${var.tank_node_count}"
  target_group_arn = "${aws_lb_target_group.tank.arn}"
  target_id        = "${element(aws_instance.tank.*.id, count.index)}"
  port             = 8888
}

resource "aws_lb_target_group_attachment" "navigator" {
  count = "${var.tank_node_count}"
  target_group_arn = "${aws_lb_target_group.navigator.arn}"
  target_id        = "${element(aws_instance.tank.*.id, count.index)}"
  port             = 8081
}

resource "aws_lb_target_group_attachment" "exhauster" {
  target_group_arn = "${aws_lb_target_group.exhauster.arn}"
  target_id        = "${aws_instance.gateway.id}"
  port             = 8082
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = "${aws_lb_target_group.grafana.arn}"
  target_id        = "${aws_instance.gateway.id}"
  port             = 3000
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