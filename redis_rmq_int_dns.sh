#!/bin/bash
###########################################################################################
# AUTHOR: Chandra Munukutla
# Description: Sequence of Steps.
# 1. Get the Hosted Zone IDs from either COMMON-NONPROD OR COMMON-PROD
# 2. Get the ResourceRecordSet value for redis.int from Either COMMON-NONPROD OR COMMON-PROD
# 3. Get the ResourceRecordSet value for rmq.int from Either COMMON-NONPROD OR COMMON-PROD
# 4. Generate Redis_RecordSet.json file for creating RecordSet
# 5. Generate RMQ_RecordSet.json file for creating RecordSet
# 6. Get the Hosted Zone IDs from the Destination AWS Account - Non-Prod or Prod.
# 7. Create the ResourceRecordSet for redis.int and rmq.int
###########################################################################################

# Validate Input
if [[ $# -eq 1 ]]; then
   echo "Enter your DESTINATION AWS Profile Name where you want to create RecordSets for redis.int and rmq.int:"
   read dest_aws_account_profile
   if [[ -z ${dest_aws_account_profile} ]]; then
      echo "ERROR: Destination AWS Account PROFILE is empty!"
	  exit 1
   fi
   echo "Enter COMMON AWS Profile Name for the ENV: For either NONPROD OR PROD based on where you want to create the redis.int and rmq.int record sets"
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
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-NONPROD
		DEV_REDIS_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${DEV_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "redis.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - RMQ - from COMMON-NONPROD
		DEV_RMQ_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${DEV_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "rmq.int.") | .ResourceRecords[].Value'`
		
	    ;;
	 qa|QA)
	    MY_ENV=QA
		# Get the Hosted Zone IDs
		QA_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("QA"))) | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-NONPROD
		QA_REDIS_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${QA_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "redis.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-NONPROD
		QA_RMQ_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${QA_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "rmq.int.") | .ResourceRecords[].Value'`
	    ;;
	 uat|UAT)
	    MY_ENV=UAT
		# Get the Hosted Zone IDs
		UAT_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(( .Name == "int.") and (.CallerReference | contains("UAT"))) | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-NONPROD
		UAT_REDIS_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${UAT_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "redis.int.") | .ResourceRecords[].Value'`
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-NONPROD
		UAT_RMQ_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${UAT_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "rmq.int.") | .ResourceRecords[].Value'`
	    ;;
	 prod|PROD)
	    MY_ENV=PROD
		# Get the Hosted Zone IDs
		PROD_COMMON_HOSTED_ZONE_ID=`aws route53 list-hosted-zones --region us-east-1 --profile ${COMMON_aws_account_profile} | jq -cr '.HostedZones[] | select(.Name == "int.") | .Id' | cut -d'/' -f3`
		
		# Get the RecordSet Values for each Env. - REDIS - from COMMON-PROD
		PROD_REDIS_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${PROD_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "redis.int.") | .ResourceRecords[].Value'`

		# Get the RecordSet Values for each Env. - RMQ - from COMMON-PROD
		PROD_RMQ_RECORDSET_VALUE=`aws route53 list-resource-record-sets --hosted-zone-id ${PROD_COMMON_HOSTED_ZONE_ID} --profile ${COMMON_aws_account_profile} | jq -cr '.ResourceRecordSets[] | select(.Name == "rmq.int.") | .ResourceRecords[].Value'`
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



DEST_ENV_REDIS_RECORDSET_VALUE="${MY_ENV}_REDIS_RECORDSET_VALUE"

# Create Redis RecordSet JSON file for the ENV.
cat > Redis_RecordSet.json <<REDIS_JSON
{
  "Comment": "CREATE/DELETE/UPSERT a record ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "redis.int",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${!DEST_ENV_REDIS_RECORDSET_VALUE}"
          }
        ]
      }
    }
  ]
}
REDIS_JSON

DEST_ENV_RMQ_RECORDSET_VALUE="${MY_ENV}_RMQ_RECORDSET_VALUE"

# Create rmq RecordSet JSON file for the ENV.
cat > RMQ_RecordSet.json <<RMQ_JSON
{
  "Comment": "CREATE/DELETE/UPSERT a record ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "rmq.int",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${!DEST_ENV_RMQ_RECORDSET_VALUE}"
          }
        ]
      }
    }
  ]
}
RMQ_JSON


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
    aws route53 change-resource-record-sets --hosted-zone-id ${intHostedZoneId} --change-batch file://Redis_RecordSet.json --region us-east-1 --profile ${dest_aws_account_profile}
    aws route53 change-resource-record-sets --hosted-zone-id ${intHostedZoneId} --change-batch file://RMQ_RecordSet.json --region us-east-1 --profile ${dest_aws_account_profile}
else
    echo "int Hosted Zone Id is Empty!"
fi
