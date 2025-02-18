# # Create Security Group for Bastion Host
# resource "aws_security_group" "bastion-sg" {
#   vpc_id = aws_vpc.vpc-2.id

#   #Inbound rule for SSH
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"  //for ssh access
#     cidr_blocks = ["0.0.0.0/0"]   //saari Ips se 80 port pr traffic enable krna
#   }

#    ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere (change for security)
#   }

#   #Outbound rule
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"   //applicable for all protocols
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "bastion-sg"
#   }
# }

# # Create Security Group for Web Server
# resource "aws_security_group" "web-sg" {
#   vpc_id = aws_vpc.vpc-2.id

#   # Allow SSH access only from Bastion Host
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     security_groups = [aws_security_group.bastion-sg.id]  # Allow SSH only from Bastion
#   }

#   # Allow HTTP access (Web Server)
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "web-sg"
#   }
# }

### Security Group for Load Balancer
resource "aws_security_group" "lb-sg-2" {
  name   = "lb-sg-2"
  vpc_id = aws_vpc.vpc-2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Security Group for Web Server (Only ALB Access Allowed)
resource "aws_security_group" "web-sg-2" {
  name   = "web-sg-2"
  vpc_id = aws_vpc.vpc-2.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg-2.id]  # Only allow traffic from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Output the ALB DNS Name
output "alb_dns_name" {
  value = aws_lb.alb-2.dns_name
}