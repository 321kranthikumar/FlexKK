
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
        Name = "AppServer-${(count.index)}"
	}
}
