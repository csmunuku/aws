#!/bin/bash
################################################################################  
# AUTHOR: Chandra Munukutla
# DESC: Non-Default VPC CIDRs in use
# pre-req - aws cli and jq tool to be installed.
# loop through profiles and get the Non-Default VPC CIDRs in use.
################################################################################

source ./aws_checks

jq_check
aws_cli_check

# the list - dev qa uat prod japan-tokyo - are Profiles we have in our ~/.aws/credentials file.
for i in dev qa uat prod japan-tokyo
do
  if [[ ${i} =~ "japan" ]]; then
     REG="--region ap-northeast-1"
  else
     REG="--region us-east-1"
  fi
  echo "for Account - ${i}"
  aws ec2 describe-vpcs ${REG} --profile ${i} | jq -cr '.Vpcs[] | select( .IsDefault == false) |.CidrBlock'
  echo "#############################"
done

