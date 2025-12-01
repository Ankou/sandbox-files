#!/bin/bash

#
#  Author:       Ricky Field
#  Date:         30/11/25
#  Description:  Removes resources created with VPCPeeringSetup.sh
#
#
#
#

# Collect variables from json file
resources=~/resources.json

VPCA=$( jq -r .VPCA $resources )
VPCB=$( jq -r .VPCB $resources )
VPCC=$( jq -r .VPCC $resources )
subnetAPub=$( jq -r .subnetAPub $resources )
subnetAPriv=$( jq -r .subnetAPriv $resources )
subnetBPub=$( jq -r .subnetBPub $resources )
subnetBPriv=$( jq -r .subnetBPriv $resources )
subnetCPub=$( jq -r .subnetCPub $resources )
subnetCPriv=$( jq -r .subnetCPriv $resources )
privRTA=$( jq -r .privRTA $resources )
privRTB=$( jq -r .privRTB $resources )
privRTC=$( jq -r .privRTC $resources )
igwA=$( jq -r .igwA $resources )
igwB=$( jq -r .igwB $resources )
igwC=$( jq -r .igwC $resources )
EC2a_sg=$( jq -r .EC2a_sg $resources )
EC2b_sg=$( jq -r .EC2b_sg $resources )
EC2c_sg=$( jq -r .EC2c_sg $resources )
ec2a_ID=$( jq -r .EC2a_ID $resources )
ec2b_ID=$( jq -r .EC2b_ID $resources )
ec2c_ID=$( jq -r .EC2c_ID $resources )


# Delete EC2 instances
echo -e "\e[31mDeleting EC2 Instances\e[0m"
aws ec2 terminate-instances --instance-ids $ec2a_ID
aws ec2 terminate-instances --instance-ids $ec2b_ID
aws ec2 terminate-instances --instance-ids $ec2c_ID

ec2status=$( aws ec2 describe-instances --instance-ids $ec2c_ID --query 'Reservations[].Instances[].State.Name' --output text  )

while [ $ec2status != "terminated" ]
do
  echo Status: $ec2status trying again in 10 seconds
  ec2status=$( aws ec2 describe-instances --instance-ids $ec2c_ID --query 'Reservations[].Instances[].State.Name' --output text  )
  sleep 10
done



# Delete Security Group
echo -e "\e[31mDeleting Security Groups\e[0m"
aws ec2 delete-security-group --group-id $EC2a_sg
aws ec2 delete-security-group --group-id $EC2b_sg
aws ec2 delete-security-group --group-id $EC2c_sg

# Delete Subnets
echo -e "\e[31mDeleting Subnets\e[0m"
aws ec2 delete-subnet --subnet-id $subnetAPub
aws ec2 delete-subnet --subnet-id $subnetAPriv
aws ec2 delete-subnet --subnet-id $subnetBPub
aws ec2 delete-subnet --subnet-id $subnetBPriv
aws ec2 delete-subnet --subnet-id $subnetCPub
aws ec2 delete-subnet --subnet-id $subnetCPriv

# Delete Route tables
echo -e "\e[31mDeleting Route Tables\e[0m"
aws ec2 delete-route-table --route-table-id $privRTA
aws ec2 delete-route-table --route-table-id $privRTB
aws ec2 delete-route-table --route-table-id $privRTC

# Detach Internet Gateway
echo -e "\e[31mDetatching Internet Gateways\e[0m"
aws ec2 detach-internet-gateway --internet-gateway-id $igwA --vpc-id $VPCA
aws ec2 detach-internet-gateway --internet-gateway-id $igwB --vpc-id $VPCB
aws ec2 detach-internet-gateway --internet-gateway-id $igwC --vpc-id $VPCC

# Delete Internet Gateway
echo -e "\e[31mDeleting Internet Gateways\e[0m"
aws ec2 delete-internet-gateway --internet-gateway-id $igwA
aws ec2 delete-internet-gateway --internet-gateway-id $igwB
aws ec2 delete-internet-gateway --internet-gateway-id $igwC

# Delete NAT gateway
#echo -e "\e[31mDeleting NAT gateway\e[0m"
#aws ec2 delete-nat-gateway --nat-gateway-id $natGateway > /dev/null 2>&1

# Delete VPC
echo -e "\e[31mDeleting Subnets\e[0m"
aws ec2 delete-vpc --vpc-id $VPCA
aws ec2 delete-vpc --vpc-id $VPCB
aws ec2 delete-vpc --vpc-id $VPCC

# Delete key-pair
aws ec2 delete-key-pair --key-name sandbox-key-pair > /dev/null 2>&1

# Cleanup files
rm -f ~/.ssh/sandbox-key-pair.pem
rm -f ~/resources.json
