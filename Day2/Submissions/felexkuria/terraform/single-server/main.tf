provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "web" {
  ami           = "ami-0e3d385fce209d85e"
  instance_type = "t2.micro"

  tags = {
    Name = "WebServer-Ec2"
  }
}
