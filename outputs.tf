output "azs" {  # Output is nothing but will give output to end user wht you goven in output.tf block
    value = data.aws_availability_zones.azs.names
  
}