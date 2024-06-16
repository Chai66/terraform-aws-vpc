## AWS VPC Module

This Module Creates following resources. We are using HA, we are getting first 2 AZ automatically.
* VPC
* Internet Gateway with VPC association
* 2 Public subnets in 1a and 1b
* 2 Private subnets in 1a and 1b
* 2 Database subnets in 1a and 1b
* Elastic IP
* NAT Gateway in 1a public subnet
* public route table
* Private route table
* Database route table
* Subnets and route tables association
* VPC peering if user requests
* Adding the peering route in default VPC , If user dont provide acceptor VPC explicitly
* Adding the peering routes in piblic, private and databsse route tables

## Inputs

* Project_name (Required) - Your project name
* environment (Required) - which environment you are working in
* VPC_cidr (Optional) - Default value is 10.0.0.0/16, user can override
* enable_dns_hostnames (Optional) - Default value is true
* common_tags (Optional) - Better to provide
* vpc_tags (Optional) -  default value is empty, type is map
* igw_tags (Optional) -  default value is empty, type is map
* public_subnets_cidr (Required) - user must provide 2 valid public subnets CIDR
* public_subnets_cidr (Optional) -  default value is empty, type is map
* private_subnets_cidr (Required) - user must provide 2 valid private subnets CIDR
* private_subnets_cidr (Optional) -  default value is empty, type is map
* database_subnets_cidr (Required) - user must provide 2 valid database subnets CIDR
* database_subnets_cidr (Optional)  -  default value is empty, type is map
* nat_gateway_tags (Optional) -  default value is empty, type is map
* public_route_table_tags (Optional) -  default value is empty, type is map
* private_route_table_tags (Optional) -  default value is empty, type is map 
* database_route_table_tags (Optional) -  default value is empty, type is map 
* is_peering_required (Optional) - Default value is false
* acceptor_vpc_id (Optional) - default value is dafault VPC id
* vpc_peering_tags (Optional) -  default value is empty, type is map

## Outputs

* vpc_id - VPC ID created
*

