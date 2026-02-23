# Author:       Ricky Field
#  Date:         23/02/26
#  Description:  Removes resources created with VPCPeeringSetup.sh
#
 
 
# Collect variables from json file
 
resources=~/resources.json
 
VPCA=$( jq -r .VPCA $resources )
subnetAPub=$( jq -r .subnetAPub $resources )
 
 # Delete Subnet
echo -e "\e[31mDeleting Subnets\e[0m"
aws ec2 delete-subnet --subnet-id $subnetAPub
 
# Delete VPC
echo -e "\e[31mDeleting VPC\e[0m"
aws ec2 delete-vpc --vpc-id $VPCA
