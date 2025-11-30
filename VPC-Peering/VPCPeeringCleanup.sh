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
aws ec2 detach-internet-gateway --internet-gateway-id $igwA
aws ec2 detach-internet-gateway --internet-gateway-id $igwB
aws ec2 detach-internet-gateway --internet-gateway-id $igwC

# Delete Internet Gateway
echo -e "\e[31mDeleting Internet Gateways\e[0m"
aws ec2 delete-internet-gateway --internet-gateway-id $igwA
aws ec2 delete-internet-gateway --internet-gateway-id $igwB
aws ec2 delete-internet-gateway --internet-gateway-id $igwC

# Delete VPC
echo -e "\e[31mDeleting Subnets\e[0m"
aws ec2 delete-vpc --vpc-id $VPCA
aws ec2 delete-vpc --vpc-id $VPCB
aws ec2 delete-vpc --vpc-id $VPCC


