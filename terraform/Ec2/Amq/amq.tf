
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# Creating VPC


module "flexInstance"  {
 source = "../../Networking/"
 vpc_cidr = "192.168.0.0/16"
aws_region = "us-east-1"
access_key = ""
secret_key = ""
key_path = ""
key_name = "Flex_key"
#sId = "${aws_subnet.private_1_subnet_us_east_1a.id}"

}
resource "aws_instance" "AMQ-1" {
    ami = "${var.amq_inst["ami_id"]}"
	count = "${var.amq_inst["instance_count"]}"
    availability_zone = "us-east-1a"
    instance_type = "${var.amq_inst["instance_type"]}"
#    subnet_id = "${aws_subnet.private_1_subnet_us_east_1a.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
		Name = "ActiveMQ-${(count.index)}"
    }
}
