provider "aws" {
  region = "us-west-1"
}
resource "aws_instance" "example" {

  ami           = "ami-0f8e81a3da6e2510a" # Amazon Linux 2 AMI in us-west-1
  instance_type = "t2.micro"

  tags = {
    Name = "FelexLabInstance"
  }
}

resource "random_id" "randomness" {
  byte_length = 16
}
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     gateway_id     = aws_internet_gateway.internet_gateway.id
#   }
#   tags = {
#     Name      = "demo_public_rtb"
#     Terraform = "true"
#   }
# }
resource "aws_s3_bucket" "my-new-S3-bucket" {   
  bucket = "my-new-tf-test-bucket-${random_id.randomness.hex}"

  tags = {     
    Name = "My S3 Bucket"     
    Purpose = "Intro to Resource Blocks Lab"   
  } 
}

resource "aws_s3_bucket_ownership_controls" "my_new_bucket_acl" {   
  bucket = aws_s3_bucket.my-new-S3-bucket.id  
  rule {     
    object_ownership = "BucketOwnerPreferred"   
  }
}
# resource "aws_security_group" "my-new-security-group" {
#   name        = "web_server_inbound"
#   description = "Allow inbound traffic on tcp/443"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description = "Allow 443 from the Internet"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "web_server_inbound"
#     Purpose = "Intro to Resource Blocks Lab"
#   }
# }