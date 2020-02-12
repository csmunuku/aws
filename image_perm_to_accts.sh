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

source ./aws_ask_file

# Name is Image Name we give when creating Image.
# Example: 2020_0209_webserver
# Input to function "ask_image_name" should be something like "2020_0209"
# So that we can get the image ID from AMI which has Name with regex "*2020_0209*"
ask_image_name
ask_region
aws ec2 describe-images \
         --filters "Name=name,Values=*${MyImageName}*" \
         --query 'Images[*].{Name:Name,ID:ImageId}' \
         --owners self \
         ${REG} \
         --profile ${MY_ROOT_PROFILE} \
         --output text | sed 's/[ \t]/,/g' > ./imageId_name.csv

for my_aws_account in ${ACCOUNTS_LIST}
do
  for my_ami in $(cut -d, -f1 imageId_name.csv)
  do
    aws ec2 modify-image-attribute \
             --image-id ${my_ami} \
             --launch-permission "Add=[{UserId=${my_aws_account}}]" \
             ${REG} \
             --profile ${MY_ROOT_PROFILE}
  done
done

