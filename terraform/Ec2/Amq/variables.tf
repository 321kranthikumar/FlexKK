variable "aws_region" {}
variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "amq_inst" {
		type = "map"
	default =	{
		ami_id = "ami-c998b6b2"
		instance_type = "t2.micro"
		instance_count = "2"
		}
}



variable "vpc_cidr" {
	default = "192.168.0.0/16"
}

variable "public_cidr" {
	default = "192.168.1.0/24"
}
variable "private_cidr" {
	default = "192.168.2.0/24"
}	

