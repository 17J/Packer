packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "packer-build-ami"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu-redis" {
  ami_name      = "${var.ami_prefix}-redis-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "ubuntu-apache2" {
  ami_name      = "${var.ami_prefix}-apache2-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "ubuntu-nginx" {
  ami_name      = "${var.ami_prefix}-nginx-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu-redis",
    "source.amazon-ebs.ubuntu-apache2",
    "source.amazon-ebs.ubuntu-nginx"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
    only = ["source.amazon-ebs.ubuntu-redis"] # only redis to ubuntu 22.04
  }

  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
    only = ["source.amazon-ebs.ubuntu-redis"] # only redis to ubuntu 22.04
  }
  provisioner "shell" {
    inline = [
      "echo Installing Apache2",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt install apache2 -y",
      "sudo systemctl status apache2",
      "sudo systemctl enable apache2"
    ]
    only = ["source.amazon-ebs.ubuntu-apache2"] # only apache2 to ubuntu 22.04
  }

  provisioner "shell" {
    inline = ["This is second last Provisioner"]
    only = ["source.amazon-ebs.ubuntu-apache2"] # only apache2 to ubuntu 22.04
  }
  provisioner "file" {
  source = "nginx.sh"
  destination = "/tmp/nginx.sh"
  only = ["source.amazon-ebs.ubuntu-nginx"]  #only applies to "source.amazon-ebs.ubuntu-nginx"
}

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh",
    ]
    only = ["source.amazon-ebs.ubuntu-nginx"] # only applies to "source.amazon-ebs.ubuntu-nginx"
  }
  post-processors {
  post-processor "vagrant" {}  # post-processor takes the AMI (or other image) that Packer created and transforms it into a Vagrant box.
  post-processor "compress" {}  # This post-processor compresses the artifacts created by Packer.
}

}
