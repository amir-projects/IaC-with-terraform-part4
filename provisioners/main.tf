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
  key_name   = "yourmentors"
  public_key = file("key-pairs/yourmentors.pub")
}

resource "aws_security_group" "sg-1" {
  name        = "yourmentors"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
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
  instance_type          = "t3.small"
  key_name               = aws_key_pair.key_pair_1.key_name
  vpc_security_group_ids = [aws_security_group.sg-1.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key-pairs/yourmentors")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "echo Public IP: ${self.public_ip} > instance_ips.txt"
  }

  tags = {
    Name = "YourMentors-VM"
  }
}