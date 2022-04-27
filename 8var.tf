# should be in same folder as resource file
variable "instancetype" {
  default = "t2.nano"
}
variable "image" {
  default = "ami-434"  
}

#if you wont mention default and when u hit terraform apply it will ask for value in terminal
# default values will be overridden by values we have described in the 8vars.tfvars value file
# even if you dont mention default in this file it will make the value in 8var.tfvars as the value file