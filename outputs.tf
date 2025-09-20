output "public_ip" {
  value = aws_eip.my_eip.public_ip
}

output "ssh_command" {
  value = "ssh -i MyTerraformKey.pem ubuntu@${aws_eip.my_eip.public_ip}"
}
