

resource "aws_vpc" "Vpc_app_EC2" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Vpc_app"
  }
}




resource "aws_vpc" "VPC_Tools" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_Tools"
  }
}




resource "aws_subnet" "subnet_app_EC2" {
  vpc_id            = aws_vpc.Vpc_app_EC2.id
  cidr_block        = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_app_EC2"
  }
}



resource "aws_subnet" "Subnet_PRV_RDS" {
  vpc_id            = aws_vpc.Vpc_app_EC2.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_availability_zone_1

  tags = {
    Name = "Subnet_PRV_RDS"
  }
}

resource "aws_subnet" "Subnet_PRV_RDS2" {
  vpc_id            = aws_vpc.Vpc_app_EC2.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.private_availability_zone_2

  tags = {
    Name = "Subnet_PRV_RDS2"
  }
}

resource "aws_subnet" "subnet_Tools" {
  vpc_id            = aws_vpc.VPC_Tools.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet_Tools"
  }
}
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.Vpc_app_EC2.id

  tags = {
    Name = "app-igw"
  }
}


resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.Vpc_app_EC2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
    }
  tags = {
    Name = "app-route-table"
  }
}




resource "aws_route_table" "aws_Route_Table_Tools" {
  vpc_id = aws_vpc.VPC_Tools.id

  tags = {
    Name = "aws_Route_Table_Tools"
  }
}

resource "aws_route_table" "private_rds_route_table" {
  vpc_id = aws_vpc.Vpc_app_EC2.id

  tags = {
    Name = "private-rds-route-table"
  }
  }
resource "aws_route_table_association" "rds_private_subnet_2_association" {
  subnet_id      = aws_subnet.Subnet_PRV_RDS2.id
  route_table_id = aws_route_table.private_rds_route_table.id
}

resource "aws_route_table_association" "app_subnet_association" {
  subnet_id      = aws_subnet.subnet_app_EC2.id
  route_table_id = aws_route_table.app_route_table.id
}


resource "aws_route_table_association" "app_private_subnet_association" {
  subnet_id      = aws_subnet.Subnet_PRV_RDS.id
  route_table_id = aws_route_table.private_rds_route_table.id
}





resource "aws_route_table_association" "tools_subnet_association" {
  subnet_id      = aws_subnet.subnet_Tools.id
  route_table_id = aws_route_table.aws_Route_Table_Tools.id
}




resource "aws_vpc_peering_connection" "app_tools" {
  vpc_id      = aws_vpc.Vpc_app_EC2.id
  peer_vpc_id = aws_vpc.VPC_Tools.id
  auto_accept = true

  tags = {
    Name = "app-tools-peering"
  }
}



resource "aws_route" "app_to_tools" {
  route_table_id            = aws_route_table.app_route_table.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_tools.id
}




resource "aws_route" "tools_to_app" {
  route_table_id            = aws_route_table.aws_Route_Table_Tools.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_tools.id
}
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for the application"
  vpc_id      = aws_vpc.Vpc_app_EC2.id

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
tags={
    Name="sg-app"
 }
}
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.Vpc_app_EC2.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}
resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.Vpc_app_EC2.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 200
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "app-nacl"
  }
}
resource "aws_network_acl_association" "app_nacl_association" {
  network_acl_id = aws_network_acl.app_nacl.id
  subnet_id     = aws_subnet.subnet_app_EC2.id
}
