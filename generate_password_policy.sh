#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: generate the cli skeleton file for the PasswordPolicy for account(s) -
#              which is to be used to set password policy for the accounts
#######################################################################################################################
source ./aws_checks

if [ $# -eq 1 ]; then
   aws iam get-account-password-policy --generate-cli-skeleton input --profile ${1}
elif [ $# -gt 1 ]; then
   for i in $*
   do
     echo "Policy JSON for ${i}"
     echo
     aws iam get-account-password-policy --generate-cli-skeleton input --profile ${i}
     echo "##########################################################################"
   done
fi
