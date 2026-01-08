#resource "tls_private_key" "ssh_key" {
#  algorithm = "RSA"
#  rsa_bits = 4096
#}

#resource "aws_key_pair" "adeife_key" {
#  key_name   = "adeife-key"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ifeoluwaaderoju6@gmail.com"
#
resource "aws_instance" "web" {
  ami           = var.web_instance_ami
  instance_type = "t3.micro"
#  key_name      = "adeife-key"

#  key_name      = aws_key_pair.adeife_key.key_name

  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "adeife-server"
  }
}

resource "aws_ssm_association" "ssm_role" {
  name = "aws_ssm_document.ssm_role.name"

  targets {
    key = "InstanceId"
    values = [aws_instance.web.id]
  }
}