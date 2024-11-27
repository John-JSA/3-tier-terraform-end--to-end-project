resource "aws_security_group" "jupiter_server_sg" {
  name        = "public_sg"
  description = "Allow SSH, HTTP, HTTPS traffic"
  vpc_id      = var.vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

}


resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_sg_id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_sg_id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


#EGRESS RULE---------------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREARING LUNCH TEMPLATE ----------------------------------------------------------
resource "aws_launch_template" "apci-aws_launch_template" {
  name_prefix   = "apci-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("scripts/frontend-server.sh"))

    network_interfaces {
    associate_public_ip_address = true
    security_groups = aws_security_group.jupiter_server_sg.id
}
}