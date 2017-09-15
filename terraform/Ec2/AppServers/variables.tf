variable "aws_region" {}
variable "access_key" {}
variable "secret_key" {}
variable "key_path" {}
variable "key_name" {}

variable "vpc_cidr" {
	default = "192.168.0.0/16"
}

variable "public_cidr" {
	default = "192.168.1.0/24"
}
variable "private_cidr" {
	default = "192.168.2.0/24"
}	
		
variable "amq_inst" {
		type = "map"
	default =	{
		ami_id = "ami-c998b6b2"
		instance_type = "t2.micro"
		instance_count = "2"
		}
}

variable "jboss_inst" {
		type = "map"
	default =	{
		ami_id = "ami-c998b6b2"
		instance_type = "t2.micro"
		instance_count = "2"
		}
}

variable "haproxy_inst" {
		type = "map"
	default =	{
		ami_id = "ami-c998b6b2"
		instance_type = "t2.micro"
		instance_count = "2"
		}
}
