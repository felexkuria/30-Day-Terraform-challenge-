# aws_eip.nat_gateway_eip:
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
  tags = {
    "Name" = "demo_igw_eip"
  }
}

# aws_internet_gateway.internet_gateway:
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "demo_igw"
  }
}

# aws_nat_gateway.nat_gateway:
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id     = aws_eip.nat_gateway_eip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet_1.id
}

# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Terraform Resource Block - To Build EC2 instance in Public Subnet
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "Ubuntu EC2 Server"
  }
}
