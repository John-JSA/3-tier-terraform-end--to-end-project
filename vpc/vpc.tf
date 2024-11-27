resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block


 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })
}



resource "aws_internet_gateway" "apci_igw" {
  vpc_id = aws_vpc.main_vpc.id

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

#subnet creation
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_1"
  })
}



resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_2"
  })
}


# PRIVATE SUBNET
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.private_subnet_cidr[0]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_1"
  }) 
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr[1]
  availability_zone = var.availability_zone[1]
  

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_2"
  }) 
}

resource "aws_subnet" "db_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.private_subnet_cidr[2]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_3"
  }) 
}


resource "aws_subnet" "db_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone = var.availability_zone[1]
  cidr_block = var.private_subnet_cidr[3]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_4"
  }) 
  }


#PUBLIC ROUTE TABLE------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "apci_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.apci_igw.id
  }


 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  }) 
}

#PUBLIC ROUTE ASSOCIATION----------------------------------------------
resource "aws_route_table_association" "public_route_associatin_1" {
  subnet_id      =aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.apci_public_rt.id
}

resource "aws_route_table_association" "public_route_association_2" {
  subnet_id      =aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.apci_public_rt.id
}

#PRIVATE SUBNET ASSOCIATION ---------------------------------------

resource "aws_eip" "elastic_ip" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-elestic-ip"
  })
}


#CREARING A NAT GATEWAY ------------------------------------------
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.elastic_ip, aws_subnet.public_subnet_1 ]
}

 #CREATING A PRIVATE ROUTE TABLE az1a--------------------------------
 

#CREATING ROUTE TABLE ASSOCIATION PRIVATE
resource "aws_route_table_association" "private_route_associatin_1" {
  subnet_id      =aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.apci_public_rt.id
}

resource "aws_route_table_association" "db_subnet_1" {
  subnet_id      =aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.apci_public_rt.id
}

#PRIVATE SUBNET ASSOCIATION FOR Az-1b---------------------------------------

resource "aws_eip" "elastic_ip_az1b" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-elestic-ip-az1b"
  })
}

#CREARING A NAT GATEWAY ------------------------------------------
resource "aws_nat_gateway" "nat_gw_az1b" {
  allocation_id = aws_eip.elastic_ip_az1b.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw_az1b"}
  )

   # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.elastic_ip_az1b, aws_subnet.public_subnet_2 ]
}

#CREATING A PRIVATE ROUTE TABLE az1b--------------------------------
 resource "aws_route_table" "apci_private_rt_az1b" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az1b.id
  }
 }


 #CREATING ROUTE TABLE ASSOCIATION PRIVATE az1b--------------------------------------------------------------------------------------------
resource "aws_route_table_association" "private_route_associatin_2" {
  subnet_id      =aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.apci_private_rt_az1b.id
}

resource "aws_route_table_association" "db_subnet_2" {
  subnet_id      =aws_subnet.db_subnet_2.id
  route_table_id = aws_route_table.apci_private_rt_az1b.id
}

