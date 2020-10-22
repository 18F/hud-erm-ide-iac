# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/web-cluster
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##############################
# security group for webserver
##############################
resource "aws_security_group" "allow_http_ssh" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP and ssh inbound connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}
#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "web" {
  name_prefix = var.name_prefix

  image_id      = var.image_id 
  instance_type = var.instance_type   
  key_name      = var.key_pair

  security_groups             = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = "100"
    volume_type = "gp2"
  }
  # ebs_block_device { # do we need 2nd block device
  #   device_name           = "/dev/xvdz"
  #   volume_type           = "gp2"
  #   volume_size           = "50"
  #   delete_on_termination = true
  # }

  user_data = <<-EOF
            #!/bin/bash
            echo "Hello, World" $HOSTNAME > index.html
            nohup busybox httpd -f -p 80 &
            EOF
  lifecycle {
    create_before_destroy = true
  }
}
##############################
# security group for elb
##############################
resource "aws_security_group" "allow_http_https" {
  name        = "${var.name_prefix}-elb-sg"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-elb-sg"
  }
}
##############################
# elastic load balancer
##############################
resource "aws_elb" "web_elb" {
  name = "${var.name_prefix}-web-elb"
  security_groups = [
    aws_security_group.allow_http_https.id
  ]
  subnets = var.public_subnet_ids

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
  listener {
    lb_port           = 443
    lb_protocol       = "https"
    instance_port     = "443"
    instance_protocol = "https"
  }
}
##############################
# auto scaling group
##############################
resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.web_elb.id
  ]

  launch_configuration = aws_launch_configuration.web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = var.private_subnet_ids

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-web"
    propagate_at_launch = true
  }

}