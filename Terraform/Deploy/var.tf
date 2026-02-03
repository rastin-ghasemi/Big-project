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

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "db_username" {
  description = "User for RDS DB."
  default = "recipeapp"
  
}
variable "db_password" {
  description = "Password for RDS DB"

}