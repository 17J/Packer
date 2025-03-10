
provider "aws" {
  region = "ap-south-1" # Ensure this matches the Packer region
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-068ce52f1f2cc9526"
  instance_type = "t2.micro" # Or your desired instance type
  key_name      = "devops" # Replace with your key pair name
  vpc_security_group_ids = ["sg-03dadd91b6cc35c6b"] # Replace with your security group ID

  tags = {
    Name = "MyNginxInstance"
 }
}