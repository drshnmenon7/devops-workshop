
provider aws {
    region = "ap-south-1"
}

resource "aws_instance" "demo" {
  ami = "ami-03c68e52484d7488f"
  instance_type = "t2.micro"
  key_name = "darshu-devops"
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
 
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access inbound and outbound"
 

  tags = {
    Name = "ssh_access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ssh_access.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ssh_access.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

