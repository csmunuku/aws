#!/bin/bash
# AUTHOR: Chandra Munukutla
# DESC: Used to change password for users in AWS.
#       Use the right profile for changing the user's password in correct account
#       NOTE: this only works for IAM users and NOT for root account.
###################################################################################
source ./aws_ask_file

jq_check

if [ $# -ne 1 ]; then
   echo "Provide username of a user as argument to this script"
   echo "To Change the user's password to a random string"
   ask_user
else
   ask_profile
   ask_region
   my_user="${1}"
   random_pass=$(aws secretsmanager get-random-password ${REG} --exclude-punctuation --password-length 8 ${PRO} | jq '.RandomPassword')
   echo "send the below random password to the user :"
   echo "${random_pass}"
   aws iam update-login-profile ${REG} --user-name ${my_user} --password ${random_pass} --password-reset-required ${PRO}
fi
