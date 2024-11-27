variable "vpc_cidr_block" {
    type = string
    
}

variable "public_subnet_cidr_block" {
    type = list(string)
    
}


variable "availability_zone" {
    type = list(string)
   
}

variable "private_subnet_cidr" {
    type = list(string)
}

variable "image_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "key_name" {
    type = string
    }