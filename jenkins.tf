#apache-security group
resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "this is inbound rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "this is inbound rule"
    from_port   = 8080
    to_port     = 8080
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
    Name = "jenkins"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0d3bbfd074edd7acb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = aws_key_pair.deployer.id
  #teuser_data              = file("script.sh")
  user_data = <<-EOF
    #!/bin/bash
      sudo yum update -y 
     sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
     sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
      sudo yum upgrade
     sudo yum install java -y 
     sudo yum install jenkins git -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins


    
  EOF
  
  tags = {
    Name = "stage-jenkins"
  }
}