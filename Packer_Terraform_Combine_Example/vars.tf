variable "ami_prefix" {
  type    = string
  default = "learn-packer-linux-aws-nginx" # Or your desired default AMI prefix
  description = "The prefix of the AMI name created by Packer"
}