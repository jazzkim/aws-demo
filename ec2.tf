locals {
  common_tags = {
    Name = "Web"
    Team = "DevOps"
  }
}
resource "aws_key_pair" "web" {
  key_name   = "web-key"
  public_key = file("~/.ssh/id_rsa.pub")
  tags       = local.common_tags
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
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
    tags = local.common_tags
}

resource "aws_ebs_volume" "web" {
  availability_zone = "us-east-2a"
  size              = 1
  tags              = local.common_tags
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web.id
  instance_id = aws_instance.web.id
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_instance" "web" {
  ami                         = "ami-0231217be14a6f3ba"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-2a"
  associate_public_ip_address = true
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  key_name                    = aws_key_pair.web.key_name
  user_data                   = file("user_data.sh")
  tags                        = local.common_tags
}