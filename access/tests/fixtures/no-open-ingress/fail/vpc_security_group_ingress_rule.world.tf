# Fails no-open-ingress. 0.0.0.0/0 on an ingress rule is the whole internet.
resource "aws_vpc_security_group_ingress_rule" "world" {
  security_group_id = "sg-0000000000000000"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
