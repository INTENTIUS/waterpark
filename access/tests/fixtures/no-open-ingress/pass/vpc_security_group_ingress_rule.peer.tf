resource "aws_vpc_security_group_ingress_rule" "peer" {
  security_group_id            = "sg-0000000000000000"
  referenced_security_group_id = "sg-1111111111111111"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
