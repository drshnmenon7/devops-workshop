
provider aws {
    region = "ap-south-1"
}

resource "aws_instance" "demo" {
  ami = "ami-03c68e52484d7488f"
  instance_type = "t2.micro"
  key_name = "darshu-devops"
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  subnet_id = aws_subnet.devops-public-subnet-01.id
  // to create multiple aws instances
for_each = toset(["jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
 
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access inbound and outbound"
  vpc_id = aws_vpc.devops-vpc.id
 

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

resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "devops-vpc"
  }

}

resource "aws_subnet" "devops-public-subnet-01"{
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags =  {
    Name = "devops-public-subnet-01"

  }

}

resource "aws_subnet" "devops-public-subnet-02" {
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags =  {
    Name = "devops-public-subnet-02"
  }

  
}

resource "aws_internet_gateway" "devops-igw" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = {
    Name = "devops-igw"
  }

}

resource "aws_route_table" "devops-public-rt" {
  vpc_id = aws_vpc.devops-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-igw.id
  }
  
}

resource "aws_route_table_association" "devops-public-rta-subnet-01" {
  subnet_id = aws_subnet.devops-public-subnet-01.id
  route_table_id = aws_route_table.devops-public-rt.id
}

resource "aws_route_table_association" "devops-public-rta-subnet-02" {
  subnet_id = aws_subnet.devops-public-subnet-02.id
  route_table_id = aws_route_table.devops-public-rt.id
  
}
