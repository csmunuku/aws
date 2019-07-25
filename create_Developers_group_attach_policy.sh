#!/bin/bash
############################################################################
# Author:      Chandra Munukutla
# Description: Create IAM Group called "Developers" and attach policy
############################################################################

source ./aws_ask_file

ask_profile
aws iam create-group --group-name Developers $PRO
for policyARN in \
    "arn:aws:iam::aws:policy/CloudWatchEventsReadOnlyAccess" \
    "arn:aws:iam::aws:policy/ReadOnlyAccess" \
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess" \
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
do
   aws iam attach-group-policy --group-name Developers --policy-arn ${policyARN} $PRO
done 
