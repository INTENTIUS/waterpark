# Fails path-matches-name on the module-call half. A leaf principal file
# named iam_role.leaf_file.tf has to hold a module called leaf_file.
module "something_else" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "leaf-file"
  description = "A leaf file whose module label does not match its path."
}
