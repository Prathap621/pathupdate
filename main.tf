provider "aws" {
  region = "us-east-1"
}

variable "ssh_password" {
  type = string
}

variable "instance_ips" {
  type    = list(string)
}

resource "aws_instance" "example" {
  ami           = "ami-01234"
  instance_type = "t2.micro"
  count         = length(var.instance_ips)

  key_name = "your-key-pair-name"

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "GIT_REPO=\"https://github.com/yourusername/your-netplan-config-repo.git\"",
      "NETPLAN_FILE=\"/etc/netplan/01-network-manager-all.yaml\"",
      "git pull $GIT_REPO"
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"  # Change to your EC2 instance's SSH user
      password = var.ssh_password
      host     = element(var.instance_ips, count.index)
    }
  }
}
