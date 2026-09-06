module "leaf_file" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "leaf-file"
  description = "A leaf file whose module label matches its path."
}
