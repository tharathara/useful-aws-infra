###Please make sure to change the AMI & EC2 instance profile 

data "aws_vpc" "mizu_qa_vpc" {
  id = "vpc-09f1e2d57a7d8edc0"  
}

# security groups
resource "aws_security_group" "ec2_sg" {
  vpc_id = data.aws_vpc.mizu_qa_vpc.id
  description = "EC2 Security Group for ${var.environment}-${var.application}"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    prefix_list_ids = ["pl-0973134495532053e"]
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups  = [aws_security_group.mizu_qa_albv2_api_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mizu_qa_albv2_api_sg" {
  vpc_id = data.aws_vpc.mizu_qa_vpc.id
  description = "LB Security Group for ${var.environment}-${var.application}"


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
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                 = "mizu-${var.environment}-${var.application}-asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = ["subnet-0025ad04a9f0860cf"]  
  launch_template {
    id      = aws_launch_template.ec2_instance.id
    version = "$Latest"
  }
  # Associate security groups with the network interface
  target_group_arns   = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "mizu-${var.environment}-${var.application}"
    propagate_at_launch = true
  }
}

#  Launch Template
resource "aws_launch_template" "ec2_instance" {
  name                   = "mizu-${var.environment}-${var.application}-LT"
  image_id               = "ami-0f11b8b3ec240568f"  # Mizu-api-Baseimage
  instance_type          = "t3a.small"
#  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  network_interfaces {
    associate_public_ip_address = true

    security_groups = [
      aws_security_group.ec2_sg.id,
    ]
  }

  iam_instance_profile {
    name = "mizu-qa-web-role-new"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mizu-${var.environment}-${var.application}-server"
    }
  }
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "mizu-${var.environment}-${var.application}-lb"
  subnets            = ["subnet-0025ad04a9f0860cf", "subnet-0066f13ca8756ccd6"]  # Replace with the ID of your existing subnet
  security_groups    = [aws_security_group.mizu_qa_albv2_api_sg.id]
}

# ALB Target Group
resource "aws_lb_target_group" "target_group" {
  name     = "mizu-${var.environment}-${var.application}-lb-tg"
  port     = 3000 #application Traffic port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.mizu_qa_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# ALB Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80 #LB Trafic port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

