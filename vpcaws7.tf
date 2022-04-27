provider "aws" {
    region = "us-east-1"
    access_key = "dd"
    secret_key =  "dd"
} 
resource "aws_vpc" "cloudvpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags = {
      "Name" = "cloudvpc"
    }
}
resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.cloudvpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        "Name" ="public-subnet"
    } 
}
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.cloudvpc.id
    cidr_block = "10.0.2.0/24"

    tags = {
        "Name" ="private-subnet"
    } 
}
resource "aws_security_group" "cloud-sg" {
  name        = "cloud-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cloudvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cloudsg"
  }
} 
  resource "aws_internet_gateway" "cloud-gateway" {
  vpc_id = aws_vpc.cloudvpc.id

  tags = {
    Name = "cloud-gateway"
  }
}
resource "aws_internet_gateway_attachment" "cloud-attach" {
  internet_gateway_id = aws_internet_gateway.cloud-gateway.id
  vpc_id              = aws_vpc.cloudvpc.id
}
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cloudvpc.id

  route {
    cidr_block = "0.0.0.0/0"  # where to send traffic for this route table
    gateway_id = aws_internet_gateway.cloud-gateway.id    # through internet gateway
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id    # associate subnet 
  route_table_id = aws_route_table.public-rt.id   # associate the publuc route table
}
resource "aws_key_pair" "cloud-key" {
  key_name   = "cloud-key"
  public_key = "ssh-rsa ssh-keygen keypair will create and enter here for"
}
resource "aws_instance" "web-ec2" {    # create instance which i want to make in public subnet
  ami           = "ami-0a3277ffce9146b74"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-subnet.id  # associate instance with public subnet
  vpc_security_group_ids = [aws_security_group.cloud-sg.id]
  key_name = "cloud-key"
  associate_public_ip_address = true  # adding a public address to the ec2 or ypu can add elastic ip

  tags = {
    Name = "cloud-ec2"
  }
}
resource "aws_instance" "db-ec2" {    # create instance which i want to make in private subnet
  ami           = "ami-0a3277ffce9146b74"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private-subnet.id  # associate instance with private subnet
  vpc_security_group_ids = [aws_security_group.cloud-sg.id]
  key_name = "cloud-key"

  tags = {
    Name = "db-ec2"
  }
}
resource "aws_eip" "cloud-ip" {   # creating a public ip to use in nat gateway
    vpc = true
  
}
resource "aws_nat_gateway" "cloud-nat" {
  allocation_id = aws_eip.cloud-ip.id    # associate public ip with nat gateway
  subnet_id     = aws_subnet.public-subnet.id       # subnet where you want t0 create pointing towards internet 

  tags = {
    Name = "cloud NAT"
  }
}
# associate route table for nat gateway so entry into private route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.cloudvpc.id

  route {
    cidr_block = "0.0.0.0/0"  # where to send traffic for this route table
    gateway_id = aws_nat_gateway.cloud-nat.id    # through internet gateway
  }

  tags = {
    Name = "private-rt"
  }
}
# associate subnet for this route table private subnet
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id    # associate subnet private-subnet 
  route_table_id = aws_route_table.private-rt.id   # associate the private route table
}


