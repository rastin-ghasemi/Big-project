variable "Prefix" {
  description = "The name of project"
  default     = "Deploy-Project"
}
variable "Project" {
  description = "The name of project"
  default     = "Big_project-Deploy"
}


variable "contact" {
  description = "Who Responsible for this Infra"
  default     = "rastinghasemi5@gmail.com"
}
variable "terraform-state-locking" {
  description = "TF state Bucket Locking"
  default     = "terraform-state-locking"
}
