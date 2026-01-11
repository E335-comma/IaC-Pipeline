resource "aws_iam_role" "ssm_role" {
  name = "SSMRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
   Statement = [
     {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "web" {
  ami           = var.web_instance_ami
  instance_type = "t3.micro"
  iam_instance_profile = data.aws_iam_instance_profile.ssm_instance_profile.name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "adeife-server"
  }
}
