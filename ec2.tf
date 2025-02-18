# # Create Bastion Host (Jump Server)
# resource "aws_instance" "bastion-host" {
#   ami                         = "ami-00bb6a80f01f03502"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public-subnet-2.id
#   vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
#   associate_public_ip_address = true
#   key_name                    = "local-ssh"
#   tags = {
#     Name = "bastion-host"
#   }
# }


# resource "aws_key_pair" "local-ssh" {
#   key_name   = "local-ssh"            # Name for your key pair
#   public_key = file("~/.ssh/id_ed25519.pub") # Path to your public key file
# }

# Create Web Server in Private Subnet
resource "aws_instance" "web-server" {
  ami                    = "ami-00bb6a80f01f03502"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-subnet-2.id
  key_name               = "local-ssh"
  security_groups        = [aws_security_group.web-sg-2.id]
  availability_zone      = "ap-south-1b"
  associate_public_ip_address = false 

  # Steps to install nginx inside EC2 instance
  user_data = <<-EOF
            #!/bin/bash
            sudo apt install -y nginx
            sudo systemctl start nginx
            sudo systemctl enable nginx
            EOF
  tags = {
    Name = "web-server"
  }
}

//create Application Load Balancer
resource "aws_lb" "alb-2" {
  name               = "alb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg-2.id]
  subnets            = [
                      aws_subnet.public-subnet-2.id, 
                      aws_subnet.private-subnet-2.id
  ]

  tags = {
    Name = "alb-2"
  }
}

//create a target group
resource "aws_lb_target_group" "target-group-2" {
  name     = "target-group-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-2.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
  depends_on = [aws_lb.alb-2]
}

### Attach Web Server to Target Group
resource "aws_lb_target_group_attachment" "web-server-attachment-2" {
  target_group_arn = aws_lb_target_group.target-group-2.arn
  target_id        = aws_instance.web-server.id
  port            = 80
}

### Create Listener for HTTP Traffic (entrypoint point of lb, handles incoming requests)
resource "aws_lb_listener" "http-listener-2" {
  load_balancer_arn = aws_lb.alb-2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group-2.arn
  }
}