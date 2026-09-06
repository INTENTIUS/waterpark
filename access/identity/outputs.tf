output "permission_sets" {
  description = "The permission sets the human principals compile to, by principal name."
  value = {
    platform      = module.platform.permission_set_arn
    course-author = module.course_author.permission_set_arn
  }
}
