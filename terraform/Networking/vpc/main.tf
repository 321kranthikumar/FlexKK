# creating vpc module

variable "vpc_out" {}

# output "vpc_id1"{
#  value = "${var.vpc_out}"
# }

#module "vpc"{
 # source = "./vpc"

 vpc_out = "${aws_vpc.vpc_flex.id}"

# }

 output "vpc_vpc_output" {
  value = "${module.vpc.vpc_id1}"
 }
