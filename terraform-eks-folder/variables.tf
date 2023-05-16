# Variables allow you to pass in values dynamically and make your code reusable.
# Here, we specify the default values for the 2 subnets mentioned in the main.tf file


variable "subnet_id_1" {
  type = string
  default = "subnet-your_first_subnet_id"
}
 
variable "subnet_id_2" {
  type = string
  default = "subnet-your_second_subnet_id"
}
