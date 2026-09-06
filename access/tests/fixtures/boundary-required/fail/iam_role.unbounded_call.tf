# A principal file that forgot the boundary. tflint reads the calling
# directory only, so the role inside the module is invisible here and the file
# name is what says this call produces one.
module "unbounded_call" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "unbounded-call"
  description = "A workload role declared with no boundary."
  teams       = ["platform"]
}
