 provider "aws" {
  region     = "us-west-2"
  access_key = "AKIAVU2W74WF6P66W5NJ"
  secret_key = "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"
}

#VPC
resource "aws_vpc" "TF-vpc" {
  cidr_block = "11.11.0.0/16"

  tags = {
    Name = "TF-vpc"
  }
}

#subnet
resource "aws_subnet" "TF-subnet" {
  vpc_id            = aws_vpc.TF-vpc.id
  cidr_block        = "11.11.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "TF-subnet"
  }
}

resource "aws_subnet" "TF-subnet2" {
  vpc_id            = aws_vpc.TF-vpc.id
  cidr_block        = "11.11.20.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "TF-subnet2"
  }
}

#Instance
resource "aws_network_interface" "NetworkInterface" {
  subnet_id   = aws_subnet.TF-subnet.id
  private_ips = ["11.11.10.10"]

  tags = {
    Name = "TF-instance"
  }
}

resource "aws_instance" "TF-instance" {
  ami           = "ami-0cfa91bdbc3be780c" 
  instance_type = "t2.micro"
  tags = {
    Name = "TF-instance"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "TF-IG" {
  vpc_id = aws_vpc.TF-vpc.id

  tags = {
    Name = "TF-IG"
  }
} 

#Route Table
resource "aws_route_table" "TF-routetable" {
  vpc_id = aws_vpc.TF-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF-IG.id
  }

  tags = {
    Name = "TF-routetable" 
  }
}
#Association IG to route table
resource "aws_route_table_association" "IG-RT" {
  gateway_id     = aws_internet_gateway.TF-IG.id
  route_table_id = aws_route_table.TF-routetable.id
}

#Association subnet to route table
resource "aws_route_table_association" "SN-RT" {
  subnet_id      = aws_subnet.TF-subnet.id
  route_table_id = aws_route_table.TF-routetable.id
}

#Nat GateWay
resource "aws_nat_gateway" "TF-NG" {
  connectivity_type = "private"
  subnet_id     = aws_subnet.TF-subnet2.id

  tags = {
    Name = "TF-NG"
  }
}

#Route Table
resource "aws_route_table" "TF-routetable2" {
  vpc_id = aws_vpc.TF-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.TF-NG.id
  }

  tags = {
    Name = "TF-routetable" 
  }
}

#Association NG to route table
resource "aws_route_table_association" "NG-RT" {
  gateway_id     = aws_nat_gateway.TF-NG.id
  route_table_id = aws_route_table.TF-routetable2.id
}

#Association subnet to route table
resource "aws_route_table_association" "SN2-RT" {
  subnet_id      = aws_subnet.TF-subnet2.id
  route_table_id = aws_route_table.TF-routetable2.id
}
