# 🔑 Generate SSH key
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 🔑 Upload public key to AWS
resource "aws_key_pair" "my_keypair" {
  key_name   = "MyTerraformKey"
  public_key = tls_private_key.my_key.public_key_openssh
}

# 🔐 Security Group for SSH + HTTP
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH and HTTP"

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

# 🖥️ EC2 instance
resource "aws_instance" "my_server" {
  ami                    = "ami-0cfde0ea8edd312d4" # Ubuntu 22.04 in us-east-1
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_keypair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "MyTerraformServer"
  }
}

# 🌐 Elastic IP
resource "aws_eip" "my_eip" {
  instance = aws_instance.my_server.id
}

# 💾 Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "${path.module}/MyTerraformKey.pem"
}
