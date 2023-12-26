#apache-security group
resource "aws_security_group" "ngnix" {
  name        = "ngnix"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "this is inbound rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ngnix"
  }
}
# apache instance

resource "aws_instance" "ngnix" {
  ami                    = "ami-0d3bbfd074edd7acb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = [aws_security_group.ngnix.id]
  key_name               = aws_key_pair.deployer.id
  #user_data              = data.template_file.apacheuser.rendered
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
     yum install nginx -y
    sudo systemctl restart nginx
    sudo systemctl status nginx
  EOF
  tags = {
    Name = "ngnix-server"
  }
}