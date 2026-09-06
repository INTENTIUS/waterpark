# Fails sg-reference-not-cidr. A hardcoded range goes stale the day the
# network is renumbered, and nothing tells you.
resource "aws_vpc_security_group_ingress_rule" "office" {
  security_group_id = "sg-0000000000000000"
  cidr_ipv4         = "10.0.0.0/8"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
