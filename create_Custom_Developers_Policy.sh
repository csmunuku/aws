#!/bin/bash
#################################################################################
# Author:      Chandra Munukutla
# Description: Create and Attach a Custom Developers Policy to Developers group
#################################################################################
source ./aws_ask_file

ask_region
ask_profile
ask_policy_file

# Create Custom policy
# aws iam create-policy ${REG} --policy-name dev-permissions --policy-document file://Custom-Developers-Policy.json $PRO | jq -cr '.Policy.Arn'
aws iam create-policy ${REG} --policy-name dev-permissions --policy-document file://${MY_POLICY} $PRO > policy_output.txt

POLICY_ARN=$(grep "arn:aws:iam::" policy_output.txt | cut -d'"' -f4)

# Attach Custom Policy to Developers group.
aws iam attach-group-policy --group-name Developers --policy-arn "${POLICY_ARN}" $PRO

# removing the policy_output.txt
rm policy_output.txt

# For creating in-line policy - we use put-group-policy
#aws iam put-group-policy ${REG} --group-name Developers --policy-document file://${MY_POLICY} --policy-name dev-permissions $PRO

