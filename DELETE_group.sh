#!/bin/bash
####################################################################
# Author:      Chandra Munukutla
# Description: Delete an IAM Group for a specific account/profile
#              Specify the group name as argument to the script.
####################################################################
# Since IAM is global, you don't have to provide/get Region info

source ./aws_ask_file

if [[ $# -eq 1 ]]; then
   ask_profile
   my_group="${1}"
   aws iam delete-group --group-name ${my_group} $PRO
else
   echo "Provide a group name as argument to this script to DELETE it!"
   ask_group
   ask_profile
   aws iam delete-group --group-name ${my_group} $PRO
fi
