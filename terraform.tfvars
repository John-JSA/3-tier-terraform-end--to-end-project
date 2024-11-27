vpc_cidr_block = "10.0.0.0/16"
 public_subnet_cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
 availability_zone = ["us-east-1a", "us-east-1b"]
private_subnet_cidr = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
image_id      = "ami-06b21ccaeff8cd686"
instance_type = t2.micro
 key_name = "jsa-keys"