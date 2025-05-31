provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true  # Enable DNS hostnames
  enable_dns_support   = true  # Enable DNS support
}

resource "aws_internet_gateway" "web_igw" {  # Add Internet Gateway
  vpc_id = aws_vpc.web_vpc.id
}

resource "aws_route_table" "web_rt" {  # Add Route Table
  vpc_id = aws_vpc.web_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}

resource "aws_route_table_association" "web_rta" {  # Associate Route Table with Subnet
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.web_rt.id
}

resource "aws_subnet" "web_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" // Replace with your desired AZ
  map_public_ip_on_launch = true
}

resource "aws_security_group" "webserverSG" {
  name_prefix = "webserverSG"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound traffic"
  }

  ingress {  # Add SSH rule
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server"
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0e3d385fce209d85e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.web_subnet.id
  vpc_security_group_ids = [aws_security_group.webserverSG.id]
  // key_name              = "hashirule"  # Remove or replace with a valid key pair name
  tags = {
    Name = "web-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x
              REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
              AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>Hello from AWS EC2</h1><h2>Region: $REGION</h2><h3>Availability Zone: $AZ</h3><h4>AMI ID: $AMI_ID</h4></body></html>" > /var/www/html/index.html
              chmod 644 /var/www/html/index.html
              EOF
}
