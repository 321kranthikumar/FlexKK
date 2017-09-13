provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
/*
Creating VPC
*/

resource "aws_vpc" "vpc_flex" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Flex-VPC"
  }
}

/*
Creating Public Subnet
*/

resource "aws_subnet" "public_subnet_us_east_1a" {
  vpc_id                  = "${aws_vpc.vpc_flex.id}"
  cidr_block              = "${var.public_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "Subnet az 1a"
  }
}


/*
Create Private Subnet 
*/
resource "aws_subnet" "private_1_subnet_us_east_1a" {
  vpc_id                  = "${aws_vpc.vpc_flex.id}"
  cidr_block              = "${var.private_cidr}"
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "Subnet private 1 az 1a"
  }
}

/*
Create Internet Gateway 
*/

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_flex.id}"
  tags {
        Name = "InternetGateway"
    }
} 

/*
Create Route to Internet
*/

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_flex.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

/*
Creating Elastic IP
*/

resource "aws_eip" "flex_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

/* Create NAT Gateway 
*/

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.flex_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us_east_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

/*
Creating Private Route Table 
*/

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

/*
Create Route Table Associations 
*/

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



#creating Public Instace

resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_flex.id}"

    tags {
        Name = "Ha-proxy-SG"
    }
}

resource "aws_instance" "haproxy-1" {
    ami = "${var.haproxy_inst["ami_id"]}"
	count = "${var.haproxy_inst["instance_count"]}"
    availability_zone = "us-east-1a"
    instance_type = "${var.haproxy_inst["instance_type"]}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.private.id}"]
    subnet_id = "${aws_subnet.private_1_subnet_us_east_1a.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "Haproxy-${(count.index)}"
	}
}

#Creating ActiveMQ instances 


resource "aws_security_group" "private" {
    name = "vpc_AMQ"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_flex.id}"

    tags {
        Name = "ActiveMQ-SG"
    }
}

resource "aws_instance" "AMQ-1" {
    #ami = "${lookup(var.amis, var.aws_region)}"
    ami = "${var.amq_inst["ami_id"]}"
	count = "${var.amq_inst["instance_count"]}"
    availability_zone = "us-east-1a"
    instance_type = "${var.amq_inst["instance_type"]}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.private.id}"]
    subnet_id = "${aws_subnet.private_1_subnet_us_east_1a.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
		Name = "ActiveMQ-${(count.index)}"
    }
}


#Creating Jboss instances 


resource "aws_security_group" "jboss" {
    name = "vpc_jboss"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_flex.id}"

    tags {
        Name = "Jboss-SG"
    }
}

resource "aws_instance" "jboss-1" {
    #ami = "${lookup(var.amis, var.aws_region)}"
    ami = "${var.jboss_inst["ami_id"]}"
	count = "${var.jboss_inst["instance_count"]}"
    availability_zone = "us-east-1a"
    instance_type = "${var.amq_inst["instance_type"]}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.private.id}"]
    subnet_id = "${aws_subnet.private_1_subnet_us_east_1a.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "Jboss-${(count.index)}"
	}
}

