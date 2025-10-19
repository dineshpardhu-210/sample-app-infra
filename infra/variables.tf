variable "aws_region"      { default = "us-east-1" }
variable "name_prefix"     { default = "sample" }
variable "vpc_cidr"        { default = "10.0.0.0/16" }
variable "ssh_key_name"    { description = "Existing EC2 key pair" }
