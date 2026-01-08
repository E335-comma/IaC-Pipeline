data "aws_iam_role" "ssm_role" {
  name = "AmazonSSMRoleForEC2"
  name = "AWSSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = data.aws_iam_role.ssm_role.name
}

resource "aws_instance" "web" {
  ami           = var.web_instance_ami
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "adeife-server"
  }
}
