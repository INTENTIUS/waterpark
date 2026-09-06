module "course_author" {
  source = "../modules/persona"

  persona     = "reader"
  name        = "course-author"
  description = "Writes lessons, reads everything, writes nothing in prod."

  identity_center = true
  accounts        = var.accounts
  principal_id    = var.course_author_group_id
  principal_type  = "GROUP"
  teams           = ["course"]
}
