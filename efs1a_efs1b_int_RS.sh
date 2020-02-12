#!/bin/bash
###########################################################################################
# AUTHOR: Chandra Munukutla
# Description: Sequence of Steps.
# 1. Get the Hosted Zone IDs from either COMMON-NONPROD OR COMMON-PROD
# 2. Get the ResourceRecordSet value for efs1a.int from Either COMMON-NONPROD OR COMMON-PROD
# 3. Get the ResourceRecordSet value for efs1b.int from Either COMMON-NONPROD OR COMMON-PROD
# 4. Generate efs1a.json and efs1b.json files for creating RecordSets
# 5. Get the Hosted Zone IDs from the Destination AWS Account - Non-Prod or Prod.
# 6. Create the ResourceRecordSet for efs1a.int and efs1b.int
###########################################################################################

# Validate Input
if [[ $# -eq 1 ]]; then
   echo "Enter your DESTINATION AWS Profile Name where you want to create RecordSets for efs1a.int and efs1b.int:"
   read dest_aws_account_profile
   if [[ -z ${dest_aws_account_profile} ]]; then
      echo "ERROR: Destination AWS Account PROFILE is empty!"
	  exit 1
   fi
   echo "Enter COMMON AWS Profile Name for the ENV: For either NONPROD OR PROD based on where you want to create the efs1a.int and efs1b.int record sets"
   read COMMON_aws_account_profile
   if [[ -z ${COMMON_aws_account_profile} ]]; then
      echo "ERROR: COMMON PROFILE is empty!"
	  exit 1
   fi
   case $1 in
     dev|DEV)
	    MY_ENV=DEV
		# Get the Hosted Zone IDs
		DEV_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("DEV"))) | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - efs1a - from COMMON-NONPROD
		DEV_efs1a_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${DEV_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1a.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - efs1b - from COMMON-NONPROD
		DEV_efs1b_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${DEV_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1b.int.") | .ResourceRecords[].Value'`
		
	    ;;
	 qa|QA)
	    MY_ENV=QA
		# Get the Hosted Zone IDs
		QA_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("QA"))) | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - efs1a - from COMMON-NONPROD
		QA_efs1a_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${QA_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1a.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - efs1b - from COMMON-NONPROD
		QA_efs1b_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${QA_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1b.int.") | .ResourceRecords[].Value'`
	    ;;
	 uat|UAT)
	    MY_ENV=UAT
		# Get the Hosted Zone IDs
		UAT_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("UAT"))) | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - efs1a - from COMMON-NONPROD
		UAT_efs1a_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${UAT_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1a.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - efs1b - from COMMON-NONPROD
		UAT_efs1b_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${UAT_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1b.int.") | .ResourceRecords[].Value'`
	    ;;
	 prod|PROD)
	    MY_ENV=PROD
		# Get the Hosted Zone IDs
		PROD_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(.Name == "int.") | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - efs1a - from COMMON-PROD
		PROD_efs1a_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${PROD_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1a.int.") | .ResourceRecords[].Value'`

		# Get the RecordSet Values for each Env. - efs1b - from COMMON-PROD
		PROD_efs1b_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${PROD_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "efs1b.int.") | .ResourceRecords[].Value'`
	    ;;
	 *) echo "ERROR: ENV Provided is NOT valid."
	    echo "Valid values - dev/qa/uat/prod"
	    exit 1
		;;
   esac
else
   echo "ERROR:"
   echo "Provide ENV as an argument"
   echo "Valid values - DEV/QA/UAT/PROD"
   exit 1
fi



DEST_ENV_efs1a_RECORDSET_VALUE="${MY_ENV}_efs1a_RECORDSET_VALUE"

# Create efs1a RecordSet JSON file for the ENV.
cat > efs1a.json <<efs1a_JSON
{
  "Comment": "CREATE/DELETE/UPSERT a record ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "efs1a.int",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${!DEST_ENV_efs1a_RECORDSET_VALUE}"
          }
        ]
      }
    }
  ]
}
efs1a_JSON

DEST_ENV_efs1b_RECORDSET_VALUE="${MY_ENV}_efs1b_RECORDSET_VALUE"

# Create efs1b RecordSet JSON file for the ENV.
cat > efs1b.json <<efs1b_JSON
{
  "Comment": "CREATE/DELETE/UPSERT a record ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "efs1b.int",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${!DEST_ENV_efs1b_RECORDSET_VALUE}"
          }
        ]
      }
    }
  ]
}
efs1b_JSON


# DESTINATION
case ${MY_ENV} in
   DEV)
      intHostedZoneId=$(aws route53 list-hosted-zones --region us-east-1 --profile ${dest_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("DEV"))) | .Id' | cut -d'/' -f3)
      ;;
   QA)
      intHostedZoneId=$(aws route53 list-hosted-zones --region us-east-1 --profile ${dest_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("QA"))) | .Id' | cut -d'/' -f3)
      ;;
   UAT)
      intHostedZoneId=$(aws route53 list-hosted-zones --region us-east-1 --profile ${dest_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("UAT"))) | .Id' | cut -d'/' -f3)
      ;;
   PROD)
      intHostedZoneId=$(aws route53 list-hosted-zones --region us-east-1 --profile ${dest_aws_account_profile} | jq -cr '.HostedZones[] | select(.Name == "int.") | .Id' | cut -d'/' -f3)
      ;;
   *) echo "ERROR: ENV Provided is NOT valid."
	  echo "Valid values - dev/qa/uat/prod"
	  exit 1
      ;;
esac

if [[ -n ${intHostedZoneId} ]]; then
    echo "intHostedZoneId = ${intHostedZoneId}"
    aws route53 change-resource-record-sets --hosted-zone-id ${intHostedZoneId} --change-batch file://efs1a.json --region us-east-1 --profile ${dest_aws_account_profile}
    aws route53 change-resource-record-sets --hosted-zone-id ${intHostedZoneId} --change-batch file://efs1b.json --region us-east-1 --profile ${dest_aws_account_profile}
else
    echo "int Hosted Zone Id is Empty!"
fi
