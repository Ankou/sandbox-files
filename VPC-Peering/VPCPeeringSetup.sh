#!/bin/bash

#
#  Author:       Ricky Field
#  Date:         30/11/25
#  Description:  Creates the pre existing infrastructure needed to setup VPC Peering
#
#
#
#



# Setup script variables
greenText='\033[1;32m'
redText='\033[1;31m'
cyanText='\033[1;36m'
yellowText='\033[1;33m'
NC='\033[0m' # No Color


# Check for flags
verbosity=false

while getopts v flag; do
    case $flag in
        v) verbosity=true ;;
        \?) echo -e "UNKNOWN flag" ;;
    esac
done

echo -e "verbosity is $verbosity"




#################################
#                               #
#       VPC Configuration       #
#                               #
#################################

# Create VPCs

VPCA=$(aws ec2 create-vpc --cidr-block 172.16.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=SandboxVPC-A}]' --query Vpc.VpcId --output text)
VPCB=$(aws ec2 create-vpc --cidr-block 172.17.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=SandboxVPC-B}]' --query Vpc.VpcId --output text)
VPCC=$(aws ec2 create-vpc --cidr-block 172.18.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=SandboxVPC-C}]' --query Vpc.VpcId --output text)
if [ $verbosity == "true" ]; then read -p "Created VPCs:  Press Enter to continue..."; fi

# Create subnets in the new VPCs
subnetAPub=$(aws ec2 create-subnet --vpc-id $VPCA --cidr-block 172.16.0.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-A Public}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
subnetAPriv=$(aws ec2 create-subnet --vpc-id $VPCA --cidr-block 172.16.1.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-A Private}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
subnetBPub=$(aws ec2 create-subnet --vpc-id $VPCB --cidr-block 172.17.0.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-B Public}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
subnetBPriv=$(aws ec2 create-subnet --vpc-id $VPCB --cidr-block 172.17.1.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-B Private}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
subnetCPub=$(aws ec2 create-subnet --vpc-id $VPCC --cidr-block 172.18.0.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-C Public}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
subnetCPriv=$(aws ec2 create-subnet --vpc-id $VPCC --cidr-block 172.18.1.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-C Private}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
if [ $verbosity == "true" ]; then read -p "Created subnets:  Press Enter to continue..."; fi

# Find default route tables for each VPC
pubRTA=$(aws ec2 describe-route-tables --query "RouteTables[?VpcId == '$VPCA'].RouteTableId" --output text)
pubRTB=$(aws ec2 describe-route-tables --query "RouteTables[?VpcId == '$VPCB'].RouteTableId" --output text)
pubRTC=$(aws ec2 describe-route-tables --query "RouteTables[?VpcId == '$VPCC'].RouteTableId" --output text)
if [ $verbosity == "true" ]; then read -p "Determined VPC default route tables:  Press Enter to continue..."; fi

# Update Tags
aws ec2 create-tags --resources $pubRTA --tags 'Key=Name,Value=Public route Table for VPC-A'
aws ec2 create-tags --resources $pubRTB --tags 'Key=Name,Value=Public route Table for VPC-B'
aws ec2 create-tags --resources $pubRTC --tags 'Key=Name,Value=Public route Table for VPC-C'
if [ $verbosity == "true" ]; then read -p "Updated public route table names:  Press Enter to continue..."; fi

# Create private route table all VPCs
privRTA=$(aws ec2 create-route-table --vpc-id $VPCA --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private Route Table for VPC-A}]' --query RouteTable.RouteTableId --output text)
privRTB=$(aws ec2 create-route-table --vpc-id $VPCB --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private Route Table for VPC-B}]' --query RouteTable.RouteTableId --output text)
privRTC=$(aws ec2 create-route-table --vpc-id $VPCC --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private Route Table for VPC-C}]' --query RouteTable.RouteTableId --output text)
if [ $verbosity == "true" ]; then read -p "Created Private route tables:  Press Enter to continue..."; fi

# Associate route tables with their subnets
aws ec2 associate-route-table --subnet-id $subnetAPriv --route-table-id $privRTA --query 'AssociationState.State' --output text > /dev/null 2>&1
aws ec2 associate-route-table --subnet-id $subnetBPriv --route-table-id $privRTB --query 'AssociationState.State' --output text > /dev/null 2>&1
aws ec2 associate-route-table --subnet-id $subnetCPriv --route-table-id $privRTC --query 'AssociationState.State' --output text > /dev/null 2>&1
read -p "Associated private route tables to subnets:  Press Enter to continue..."

# Create Internet gateway for each VPC
igwA=$(aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=VPC-A-igw}]' --query InternetGateway.InternetGatewayId --output text)
igwB=$(aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=VPC-B-igw}]' --query InternetGateway.InternetGatewayId --output text)
igwC=$(aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=VPC-C-igw}]' --query InternetGateway.InternetGatewayId --output text)
if [ $verbosity == "true" ]; then read -p "Created Internet Gateways:  Press Enter to continue..."; fi

# Attach gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPCA --internet-gateway-id "$igwA"
aws ec2 attach-internet-gateway --vpc-id $VPCB --internet-gateway-id "$igwB"
aws ec2 attach-internet-gateway --vpc-id $VPCC --internet-gateway-id "$igwC"
if [ $verbosity == "true" ]; then read -p "Attached IGWs to VPCs:  Press Enter to continue..."; fi







resources=~/resources.json
JSON_STRING=$( jq -n \
        --arg VPCA $VPCA \
        --arg VPCB $VPCB \
        --arg VPCC $VPCC \
	--arg subnetAPub   $subnetAPub  \
	--arg subnetAPriv  $subnetAPriv \
	--arg subnetBPub   $subnetBPub  \
	--arg subnetBPriv  $subnetBPriv \
	--arg subnetCPub   $subnetCPub  \
	--arg subnetCPriv  $subnetCPriv \
	--arg privRTA	   $privRTA \
	--arg privRTB	   $privRTB \
	--arg privRTC	   $privRTC \
	--arg igwA	   $igwA \
	--arg igwB	   $igwB \
	--arg igwC	   $igwC \
        '{VPCA: $VPCA, VPCB: $VPCB, VPCC: $VPCC,
		subnetAPub: $subnetAPub,
		subnetAPriv: $subnetAPriv,
		subnetBPub: $subnetBPub,
		subnetBPriv: $subnetBPriv,
		subnetCPub: $subnetCPub,
		subnetCPriv: $subnetCPriv,
		privRTA: $privRTA,
		privRTB: $privRTB,
		privRTC: $privRTC,
		igwA: $igwA,
		igwB: $igwB,
		igwC: $igwC
	'})

echo $JSON_STRING > $resources


echo -e "\n${greenText}\t\t SCRIPT COMPLETED ${NC}"
