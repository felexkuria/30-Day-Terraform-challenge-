provider "aws" {
  region = "us-east-1" // Replace with your desired region
}

resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "web_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" // Replace with your desired AZ
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
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0e3d385fce209d85e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet.id
  security_groups = [aws_security_group.webserverSG.name]
  tags = {
    Name = "web-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "<html><body><h1>Region: ${AWS_REGION}</h1><h2>Subnet: ${AWS_SUBNET}</h2><h3>AZ: ${AWS_AZ}</h3></body></html>" > /var/www/html/index.html
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
}
