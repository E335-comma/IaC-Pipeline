output "private_key" {
    value = tls_private_key.ssh_key.private_key_pem
    sensitive = true
}

output "ec2_public_ip" { 
    value = aws_instance.web.public_ip
}