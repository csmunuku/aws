#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: Set PasswordPolicy for each of our Accounts.
#######################################################################################################################
source ./aws_checks
if [[ -f PasswordPolicy.json ]]; then
  echo "Provide the Profile where you would like to set the PasswordPolicy:"
  read PROFILE
  if [[ -n $PROFILE ]]; then
     echo "Setting Password Policy for - ${PROFILE}"
     aws iam update-account-password-policy --cli-input-json file://PasswordPolicy.json --profile ${PROFILE}
  fi
else
  echo "PasswordPolicy.json file is missing in the current directory!!"
fi
