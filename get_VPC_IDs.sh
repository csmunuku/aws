#!/bin/bash
#########################################################################################
# AUTHOR: Chandra Munukutla
# DESC: Get VPC ID (other than the default VPC) in an aws account.
#       Use aws profile information for accessing the account.
#       based on convetion used, this can be adjusted.. here the convention for vpc name
#       has been given as <ENV>-vpc
#########################################################################################

source ./aws_ask_file
ask_profile
ask_env

aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=*${MY_ENV}-vpc" \
        --region us-east-1 ${PRO} | jq -cr '.Vpcs[].VpcId'
