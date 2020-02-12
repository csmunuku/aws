#!/bin/bash
###########################################################################################
# AUTHOR: Chandra Munukutla
# INFO: This only applies for Non-Prod Account type. DOESN'T APPLY TO PROD
#       (as prod domain is handled via Other Domain Mgmt Company and not AWS)
# Description: Sequence of Steps.
# 1. Get the Hosted Zone IDs from Client specific Account
# 2. Get the ResourceRecordSet value for <client_name>.mytestdomain.com for Client Non-Prod Account
# 3. Generate <Client>_<Acct_Type>_RecordSet.json file for capturing NS RecordSet info
# 4. Get the Hosted Zone IDs from the ROOT AWS Account for mytestdomain.com. HostedZone.
# 5. Create the New ResourceRecordSet in the Hosted Zone (mytestdomain.com.)
###########################################################################################

# Validate Input

echo "Enter your SOURCE AWS Profile Name (for your Client Ex: client-nonprod etc) from which we need to get NS Records:"
read source_aws_account_profile
if [[ -z ${source_aws_account_profile} ]]; then
   echo "ERROR: Source AWS Account PROFILE is empty!"
   exit 1
fi
echo "Enter ROOT AWS Profile Name - where you want to create the record set for your Domain <client_name>.mytestdomain.com."
read root_aws_account_profile
if [[ -z ${root_aws_account_profile} ]]; then
   echo "ERROR: ROOT PROFILE is empty!"
  exit 1
fi
echo "We need your Domain."
echo "in the format \"<client_name>.mytestdomain.com\""
echo "Example:\"client.mytestdomain.com\""
echo "the <client_name> in the above example - \"client\" might be a short form name for a Client \"mysoftcompany\""
echo "Enter your domain name:"
read domain_name
if [[ -z ${domain_name} ]]; then
   echo "ERROR: Domain Name provided - ${domain_name} - is empty!"
  exit 1
fi

PROGRAM_HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --region us-east-1 --profile ${source_aws_account_profile} --query 'HostedZones[].{Name:Name,Id:Id}' --output text | grep "${domain_name}" | awk '{print $1}' | cut -d/ -f3)

if [[ -z ${PROGRAM_HOSTED_ZONE_ID} ]]; then
   echo "ERROR: HostedZone ID is Empty for the Profile - ${source_aws_account_profile}!!"
   exit 1
fi

ROOT_HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --region us-east-1 --profile ${root_aws_account_profile} --query 'HostedZones[].{Name:Name,Id:Id}' --output text | grep "mytestdomain.com." | awk '{print $1}' | cut -d/ -f3)

if [[ -z ${ROOT_HOSTED_ZONE_ID} ]]; then
   echo "ERROR: HostedZone ID is Empty for the Profile - ${root_aws_account_profile}!!"
   exit 1
fi

# Get the RecordSet Values for the Domain Name - ex: client.mytestdomain.com.
NS_RECORDSET_VALUE=$(aws route53 list-resource-record-sets --region us-east-1 --profile ${source_aws_account_profile} --hosted-zone-id "Z3II21CVDZQBNY" --query 'ResourceRecordSets[].{NSRecordSet:ResourceRecords,Name:Name,Type:Type}' | jq -cr '.[]|select(.Type=="NS") | .NSRecordSet')

if [[ -z ${NS_RECORDSET_VALUE} ]]; then
   echo "ERROR: NS RecordSet is Empty for the Profile - ${source_aws_account_profile}!!"
   exit 1
fi

# Create Redis RecordSet JSON file for the ENV.
cat > ${domain_name}_RecordSet.json <<${domain_name}_JSON
{
  "Comment": "NS RecordSet for ${domain_name} ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "${domain_name}.",
        "Type": "NS",
        "TTL": 300,
        "ResourceRecords": ${NS_RECORDSET_VALUE}
      }
    }
  ]
}
${domain_name}_JSON

#cat ${domain_name}_RecordSet.json

# Create the Resource RecordSet for NS Record in the "root" Account for the domain_name (specific to your Client Account)
aws route53 change-resource-record-sets --hosted-zone-id ${ROOT_HOSTED_ZONE_ID} --change-batch file://${domain_name}_RecordSet.json --region us-east-1 --profile ${root_aws_account_profile}
