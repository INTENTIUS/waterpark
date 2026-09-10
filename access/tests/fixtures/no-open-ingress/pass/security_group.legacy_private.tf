# Passes. An inline ingress from a private range is not the rule's concern,
# even if the sibling rule would still rather it named a source group.
resource "aws_security_group" "legacy_private" {
  name        = "legacy-private"
  description = "ssh from the office"
  vpc_id      = "vpc-default-us-east-1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    owner = "platform"
  }
}
