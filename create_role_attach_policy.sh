#!/bin/bash
# AUTHOR: Chandra Munukutla
# DESC: create_role_attach_policy.sh - creates a Role and Attaches a Policy
###########################################################################
if [[ $# -ne 4 ]]; then
   echo "USAGE: $0 <PROGRAM_NAME> <ACCT> <ACCT_NUM> <PROFILE>"
   echo "<PROGRAM_NAME> - examples.. PROG1/PROG2/PROG3 etc"
   echo "<ACCT> - is NonProd OR PROD"
   echo "<ACCT_NUM> - example: 123456789012"
   echo "<PROFILE> - is your AWS profile. example..  nonprod, prod etc"
   echo "Exiting now!"
   exit 1
else
   PROG="${1}"
   ACCT="${2}"
   ACCT_NUM="${3}"
   PROFILE="${4}"
fi

source ./aws_checks

# 4 users we are assuming is user1, user2, user3 and user4
(
cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789019:root",
	  "arn:aws:iam::${ACCT_NUM}:user/user1",
          "arn:aws:iam::${ACCT_NUM}:user/user2",
	  "arn:aws:iam::${ACCT_NUM}:user/user3",
          "arn:aws:iam::${ACCT_NUM}:user/user4"
        ]
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
) > ${PROG}_${ACCT}_role-policy-document.json

aws iam create-role --role-name AdminAccess-${PROG}_${ACCT} --description "Administrator Access to the ${PROG} ${ACCT} Account" --assume-role-policy-document file://${PROG}_${ACCT}_role-policy-document.json --profile ${PROFILE}

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdminAccess --role-name AdminAccess-${PROG}_${ACCT} --profile ${PROFILE}
