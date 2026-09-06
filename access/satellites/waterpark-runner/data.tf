# How a satellite consumes a central identifier (decision 50). By name, read
# live, never through terraform_remote_state.
#
# The boundary name is deterministic (decision 36), so the satellite needs one
# string rather than an ARN somebody copied. Reading it live means the
# satellite gets the boundary that actually exists rather than the one a file
# claims exists, and it means a satellite that plans before central has
# applied the boundary fails loudly rather than creating an unbounded role.
#
# terraform_remote_state was the alternative and it is refused. It would hand
# a satellite read access to the central state file, which is bookkeeping and
# never the system of record (decision 32), and it would make every satellite
# a reader of central's internals.
data "aws_iam_policy" "boundary" {
  name = var.boundary_name
}
