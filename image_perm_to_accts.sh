#!/bin/bash
# Author: Chandra Munukutla
# Desc: Share Images to specified AWS Account IDs.
#       Need to know/provide Image Name regex to share it.
#       Comment/UnComment the Accounts List according to sharing preferences.
#################################################################################
# AWS Accounts list to which you would like to share your images
# that exist in your root account.
ACCOUNTS_LIST="112233445566 778899112233"

# hardcoding root profile name
MY_ROOT_PROFILE="root_profile"

# NOTE: hardcoding region for this script to us-east-1

ask_name()
{
   echo "Provide the Image Name \"RegEx\""
   read NameRegEx
   if [[ -n "${NameRegEx}" ]]; then
      echo "Name RegEx is - ${NameRegEx}"
   else
      echo "Name RegEx is EMPTY!"
	  exit 1
   fi
}

# Name is Image Name we give when creating Image.
# Example: 2020_0209_webserver
# Input to function "ask_name" should be something like "2020_0209"
# So that we can get the image ID from AMI which has Name with regex "*2020_0209*"
ask_name
aws ec2 describe-images \
         --filters "Name=name,Values=*${NameRegEx}*" \
         --query 'Images[*].{Name:Name,ID:ImageId}' \
         --owners self \
         --region us-east-1 \
         --profile ${MY_ROOT_PROFILE} \
         --output text | sed 's/[ \t]/,/g' > ./imageId_name.csv

for my_aws_account in ${ACCOUNTS_LIST}
do
  for my_ami in $(cut -d, -f1 imageId_name.csv)
  do
    aws ec2 modify-image-attribute \
             --image-id ${my_ami} \
             --launch-permission "Add=[{UserId=${my_aws_account}}]" \
             --region us-east-1 \
             --profile ${MY_ROOT_PROFILE}
  done
done
