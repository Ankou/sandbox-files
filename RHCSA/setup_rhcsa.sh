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



