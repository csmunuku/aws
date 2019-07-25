#!/bin/bash
###################################################################################################################
# Author:      Chandra Munukutla
# Description: DELETE user(s) in specific Account(s).
###################################################################################################################
echo "AWS - DELETE User Script.."
echo "#############################"
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_manage.html#id_users_deleting_cli
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_manage.html#id_users_deleting_console
# Sequence of Steps
# 1. Delete Access Keys
# 2. Delete Signing Certificates
# 3. Delete User's password (delete-login-profile)
# 4. Deactivate/Delete the user's MFA device
# 5. Delete any policies that are attached to the user
# 6. Get a list of any groups the user was in, and remove the user from those groups.
# 7. Delete the user (delete-user)

my_user=
my_profile=

# Sourcing few files.
source ./aws_ask_file

# Step 1
get_Access_Key_Id()
{
  #echo "get_Access_Key_Id"
  aws iam list-access-keys ${USER} ${PRO} | jq -cr '.AccessKeyMetadata[] | .AccessKeyId'
}

# Step 1
delete_Access_Key()
{
  echo "delete_Access_Key"
  Access_Key_Id=${1}
  aws iam delete-access-key --access-key ${Access_Key_Id} ${USER} ${PRO}
}

# Step 2
list_Signing_Certificates()
{
  #echo "list_Signing_Certificates"
  aws iam list-signing-certificates ${USER} ${PRO} | jq -cr '.Certificates[].CertificateId'
}

# Step 2
delete_Signing_Certificate()
{
  echo "delete_Signing_Certificate"
  signing_certificate=${1}
  aws iam delete-signing-certificate ${USER} --certificate-id ${signing_certificate} ${PRO}
}

# Step 3
get_Login_Profile()
{
  echo "get_Login_Profile"
  aws iam get-login-profile ${USER} ${PRO} | jq -cr '.LoginProfile.UserName'
}

delete_Login_Profile()
{
  echo "delete_Login_Profile"
  aws iam delete-login-profile ${USER} ${PRO}
}

# Step 4
list_Virtual_MFA_Devices()
{
 # echo "list_Virtual_MFA_Devices"
  aws iam list-virtual-mfa-devices --assignment-status Assigned ${PRO} | jq -cr '.VirtualMFADevices[].SerialNumber' | grep ${my_user}
}

# Step 4
delete_Virtual_MFA_Device()
{
  echo "delete_Virtual_MFA_Device"
  serial_number=${1}
  aws iam delete-virtual-mfa-device --serial-number ${serial_number} ${PRO}
}

# Step 5  
list_User_Policies()
{
  # echo "list_User_Policies"
  # Will list out the Policy Names (not policy ARN)
  aws iam list-user-policies ${USER} ${PRO} --output text
}

# Step 5
delete_User_Policy()
{
  echo "delete_User_Policy"
  policy_Name=${1}
  aws iam delete-user-policy ${USER} --policy-name ${policy_Name} ${PRO}
}

# Step 5
# list attached user policies (managed policies)
list_Attached_User_Policies()
{
  aws iam list-attached-user-policies ${USER} ${PRO} | jq -cr '.AttachedPolicies[].PolicyArn'
}
  
# Step 5
# removes the managed policy with a specific ARN 
detach_Managed_Policy()
{
  policy_arn=${1}
  aws iam detach-user-policy ${USER} --policy-arn ${policy_arn} ${PRO}
}
  
# Step 6
list_Groups()
{
  #echo "list_Groups"
  aws iam list-groups-for-user ${USER} ${PRO} | jq -cr '.Groups[].GroupName'
}

remove_User_From_Group()
{
  echo "remove_User_From_Group"
  group_name=${1}
  aws iam remove-user-from-group ${USER} --group-name ${group_name} ${PRO}
}

# Step 7
delete_User()
{
  echo "delete_User"
  aws iam delete-user ${USER} ${PRO}
}

##########################
# CALL Functions
##########################
# functions coming from sourced files.
jq_check
ask_profile
ask_user

# Step 1
for i in $(get_Access_Key_Id)
do
  delete_Access_Key ${i}
done
# Step 2
for i in $(list_Signing_Certificates)
do
  delete_Signing_Certificate ${i}
done

# Step 3
get_Login_Profile
delete_Login_Profile

# Step 4
for i in $(list_Virtual_MFA_Devices)
do
  delete_Virtual_MFA_Device ${i}
done

# Step 5
for i in $(list_User_Policies)
do
  delete_User_Policy ${i}
done
for i in $(list_Attached_User_Policies)
do
  detach_Managed_Policy ${i}
done

# Step 6
for i in $(list_Groups)
do
  remove_User_From_Group ${i}
done

# Step 7
delete_User
