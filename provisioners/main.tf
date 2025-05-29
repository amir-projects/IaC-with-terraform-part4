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