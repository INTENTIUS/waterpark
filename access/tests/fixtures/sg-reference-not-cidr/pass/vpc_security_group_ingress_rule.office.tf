resource "aws_vpc_security_group_ingress_rule" "office" {
  security_group_id            = "sg-0000000000000000"
  referenced_security_group_id = "sg-2222222222222222"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
