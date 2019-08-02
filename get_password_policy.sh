#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: get existing PasswordPolicy for account(s)
#######################################################################################################################
source ./aws_checks

if [ $# -lt 1 ]; then
   echo "Provide your AWS profile as an argument to this script.."
   read PROFILE
   aws iam get-account-password-policy --profile ${PROFILE}
fi
if [ $# -eq 1 ]; then
   PROFILE="${1}"
   aws iam get-account-password-policy --profile ${PROFILE}
elif [ $# -gt 1 ]; then
   for PROFILE in $*
   do
     echo "PasswordPolicy for the account - ${PROFILE}"
     echo
     aws iam get-account-password-policy --profile ${PROFILE}
     echo "################################################################################"
   done
fi
