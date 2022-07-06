provider "aws" {
  region  = "eu-north-1"
  access_key = ""
  secret_key = ""
}
variable "ingressrules" {
  type    = list(number)
  default = [8080, 22]
}
resource "aws_instance" "Terraform_Instance" {
  count                  = 1
  ami                    = "ami-0ed17ff3d78e74700"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.StandartWeb.id]
  key_name               = "key"

  tags = {
    Name    = "Created using terraform"
    Owner   = "Vitaliy"
    Project = "Exam"
  }
resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
  iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" = "true"
  }
}
resource "aws_instance" "jenkins" {
  ami             = "ami-0ed17ff3d78e74700"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.web_traffic.name]
  provisioner "remote-exec"  {
    inline  = [
      "sudo apt update ",
      "sudo apt install openjdk-8-jdk ",
      "sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update",
      "sudo apt install jenkins",
      "sudo systemctl start jenkins",
      ]
   }
  connection {
    type         = "ssh"
    host         = self.public_ip
    user         = "ubuntu"
    private_key  = file()
   }
  tags  = {
    "Name"      = "Jenkins"
  }
}
