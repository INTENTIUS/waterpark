# Fails no-open-ingress on the inline shape. This is what an adopted group
# looks like straight out of -generate-config-out, and the open port is the
# same open port whichever shape declares it.
resource "aws_security_group" "legacy_open" {
  name        = "legacy-open"
  description = "ssh from anywhere"
  vpc_id      = "vpc-default-us-east-1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    owner = "platform"
  }
}
