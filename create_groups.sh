#!/bin/bash
####################################################################
# Author:      Chandra Munukutla
# Description: Create IAM Group(s) for a specific account/profile
#              Specify the group names as arguments to the script.
####################################################################

source ./aws_ask_file

if [[ $# -gt 0 ]]; then
   ask_profile
   for i in $*
   do
     aws iam create-group --group-name ${i} $PRO
   done
else
   echo "ERROR: Provide a list of group(s) as argument(s) to this script"
   echo "Exiting.."
   exit 1
fi
