locals {
  instance_type = {
    dev  = "t2.micro"
    prod = "t3.small"
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "key_pair_1" {
  key_name   = "yourmentorss"
  public_key = file("key-pairs/yourmentors.pub")
}

resource "aws_security_group" "sg-1" {
  name        = "yourmentorss"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_instance" "instance-1" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = local.instance_type[terraform.workspace]
  key_name               = aws_key_pair.key_pair_1.key_name
  vpc_security_group_ids = [aws_security_group.sg-1.id]

  tags = {
    Name = "YourMentors-VM"
  }
}