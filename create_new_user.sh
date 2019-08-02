#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: AWS - Create a User, Set Default Password, Add user to Group and
#              Display info (json) for all the users in the group.
#              The aws access and secret access keys are provided from your aws credentials file
# Usage:       Please see usage function in the script.
#######################################################################################################################

source ./aws_checks

DEFAULT_PASSWORD="password@123"
usage()
{
  echo "USAGE:"
  echo "$0 <username> <group_name> <profile>"
  echo "Example: $0 cmunukutla Admin nonprod"
  echo "Example: $0 cmunukutla Admin prod"
  echo "OR"
  echo "Example: $0 admin-users.csv"
  echo "Example: $0 dev-users.csv"
  exit 1
}

create_user()
{
  user=${1}
  user_group=${2}
  PROFILE=${3}
  aws iam create-user --user-name ${user} --profile ${PROFILE}
  aws iam create-login-profile --user-name ${user} --password "${DEFAULT_PASSWORD}" --password-reset-required --profile ${PROFILE}
  aws iam add-user-to-group --user-name ${user} --group-name ${user_group} --profile ${PROFILE}
  aws iam get-group --group-name ${user_group} --profile ${PROFILE}
}

if [[ -f $1 ]]; then
    echo "Provide your AWS profile as an argument to this script.."
    read PROFILE
    for i in $(grep -v "^#" ${1} | sed 's/,/ /g')
    do
      if [[ ${1} == "admin-users.csv" ]]; then
         create_user $i Admin $PROFILE
      elif [[ ${1} == "dev-users.csv" ]]; then
         create_user $i Developers $PROFILE
      fi
    done
elif [[ $# -eq 3 ]]; then
    user=$1
    user_group=$2
    PROFILE=$3
    create_user $user $user_group $PROFILE
else
    usage
fi

#######################################################################################################################
