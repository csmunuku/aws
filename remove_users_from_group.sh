#!/bin/bash
#######################################################################################################################
# Author:      Chandra Munukutla
# Description: Remove user(s) form group(s) in specific Account(s).
#######################################################################################################################
source ./aws_checks
echo "Specify the user info, specify a comma separated list, if you want to remove multiple users from specified groups..:"
read myuser
echo "Specify the group from which you want to remove the user(s) from:"
read mygroup
echo "specify the profile (ie., Account) which you want to run this against, specify a comma separated list, if you want to do it in multiple accounts..:"
read myprofile
if [ -z $myuser ]; then
   echo "User info you provided is empty.."
   echo "Please provide user(s) comma separated list to work with"
   exit 1
fi
if [ -z $mygroup ]; then
   echo "Group(s) you provided is empty.."
   echo "Please provide group(s) command separated list to work with"
   exit 1
fi
if [ -z $myprofile ]; then
   echo "Profile you provided is empty.."
   echo "Please provide profile to work with"
   exit 1
fi
for profile in $(echo $myprofile | tr -s ',' ' ')
do
  for usr in $(echo $myuser | tr -s ',' ' ')
  do
    for grp in $(echo $mygroup | tr -s ',' ' ')
    do
      echo "Removing user \"${usr}\" from Group \"${grp}\" from Account/Profile - \"${profile}\"."
      aws iam remove-user-from-group --user-name ${usr} --group-name ${grp} --profile ${profile}
    done
  done
done
