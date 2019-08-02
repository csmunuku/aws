#!/bin/bash
# AUTHOR: Chandra Munukutla
# Script: list_aws_users.sh
#############################################################################
source ./aws_checks
cd ~; 
profiles="$(grep -E "\[|\]" .aws/credentials | sed 's/\[//g' | sed 's/\]//g' | tr -s '\n' ' ')"
for i in $profiles
do
  echo "################################"
  echo "For Profile - $i "
  aws iam list-users --query "Users[].[UserName]" --output text --profile $i
#  aws iam list-users --profile $i | jq -cr '.Users[].UserName'
done
