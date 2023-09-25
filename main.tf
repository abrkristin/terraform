provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.79.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.79.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Public subnet a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.79.2.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Public subnet b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.79.3.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Private subnet a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.79.4.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Private subnet b"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Public route table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private route table"
  }
}

resource "aws_route" "public_to_internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private_to_nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.allocation_id
  subnet_id = aws_subnet.public_a.id
}

resource "aws_eip" "main" {
  domain = "vpc"
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "My Security Group"
  
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group"
  }
}


resource "aws_instance" "ubuntu" {
  ami = "ami-0ab1a82de7ca5889c"
  instance_type = "t2.micro"
  key_name = "jenkins-key"
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "Jenkins Master"
  }

  associate_public_ip_address = true
}
