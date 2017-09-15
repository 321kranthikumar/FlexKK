provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# Creating VPC


resource "aws_vpc" "vpc_flex" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Flex-VPC"
  }
}


# Creating Public Subnet


resource "aws_subnet" "public_subnet_us_east_1a" {
  vpc_id                  = "${aws_vpc.vpc_flex.id}"
  cidr_block              = "${var.public_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "Public Subnet"
  }
}



# Create Private Subnet 

resource "aws_subnet" "private_1_subnet_us_east_1a" {
  vpc_id                  = "${aws_vpc.vpc_flex.id}"
  cidr_block              = "${var.private_cidr}"
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "private Subnet "
  }
}


# Create Internet Gateway 


resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_flex.id}"
  tags {
        Name = "InternetGateway"
    }
} 


# Create Route to Internet


resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_flex.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}


# Creating Elastic IP


resource "aws_eip" "flex_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create NAT Gateway 


resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.flex_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us_east_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
	
}


# Creating Private Route Table 


resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_flex.id}"
 
    tags {
        Name = "Private route table"
    }
}
 
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}


# Create Route Table Associations 


# Associate subnet public_subnet_us_east_1a to public route table
resource "aws_route_table_association" "public_subnet_us_east_1a_association" {
    subnet_id = "${aws_subnet.public_subnet_us_east_1a.id}"
    route_table_id = "${aws_vpc.vpc_flex.main_route_table_id}"
}
 
# Associate subnet private_1_subnet_us_east_1a to private route table
resource "aws_route_table_association" "pr_1_subnet_us_east_1a_association" {
    subnet_id = "${aws_subnet.private_1_subnet_us_east_1a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
