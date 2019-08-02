#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: AWS - Create Dev Users, Set Default Password, Add user to Developers Group and
#              Display info (json) for all the users in the group.
#              The aws access and secret access keys are provided from your aws credentials file
# Usage:       Please see usage function in the script.
#######################################################################################################################
usage()
{
  echo "USAGE:"
  echo "./$0 <user_list_file.csv> <profile>"
  echo "Example: ./$0 dev-users.csv nonprod"
  exit 1
}

if [ $# -ne 2 ]; then
    usage
fi
 
source ./aws_checks
input_file=$1
user_group="Developers"
my_profile=$2
if [[ -f ${input_file} ]]; then
  dos2unix $input_file
  for user in $(cat ${input_file} | /usr/bin/tr ',' ' ')
  do
    aws iam create-user --user-name ${user} --profile ${my_profile}
    aws iam create-login-profile --user-name ${user} --password Euphoria@1 --password-reset-required --profile ${my_profile}
    aws iam add-user-to-group --user-name ${user} --group-name ${user_group} --profile ${my_profile}
    aws iam get-group --group-name ${user_group} --profile ${my_profile}
  done
fi
#######################################################################################################################
