variable "aws_region" {}
variable "access_key" {}
variable "secret_key" {}
variable "key_path" {}
variable "key_name" {}
		
variable "amq_inst" {
		type = "map"
	default =	{
		ami_id = "ami-c998b6b2"
		instance_type = "t2.micro"
		instance_count = "2"
		}
}
