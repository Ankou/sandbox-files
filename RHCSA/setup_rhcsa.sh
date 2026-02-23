#!/bin/bash

#
#  Author:       Ricky Field
#  Date:         23/02/26
#  Description:  Creates basic RHEL environment to practice for RHCSA exam
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

if [ $verbosity == "true" ]; then echo -e "verbosity is $verbosity"; fi


#################################
#                               #
#       VPC Configuration       #
#                               #
#################################

# Create VPCs
VPCA=$(aws ec2 create-vpc --cidr-block 172.16.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=SandboxVPC-A}]' --query Vpc.VpcId --output text)
if [ $verbosity == "true" ]; then echo -e "Created VPC:"; fi

# Create Subnet
subnetAPub=$(aws ec2 create-subnet --vpc-id $VPCA --cidr-block 172.16.0.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=VPC-A Public}]' --availability-zone us-east-1a --query Subnet.SubnetId --output text)
if [ $verbosity == "true" ]; then echo -e "Created subnet:"; fi

resources=~/resources.json
JSON_STRING=$( jq -n \
    --arg VPCA $VPCA \
    --arg subnetAPub $subnetAPub \
	'{
	    VPCA: $VPCA, subnetAPub: $subnetAPub
	'})

echo $JSON_STRING > $resources

