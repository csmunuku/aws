#!/bin/bash

source ./aws_checks
ask_profile
ask_env

aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*${MY_ENV}-vpc" --region us-east-1 ${PRO} | jq -cr '.Vpcs[].VpcId'
