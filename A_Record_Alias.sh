#!/bin/bash
# AUTHOR: Chandra Munukutla
# DESC: AWS Route 53 specific.  Can be useful if you have to update Many A Records.
#       Create A Record Aliases pointing to your Web Server ALB endpoint
#       For your main site domain/sub domains provide the list in Domain_Array bash array.
# Pre-Reqs: 
#       Hardcode your ALB AWS Profile,
#       ALB Endpoint,
#       Domain/Subdomain list in Domain_Array and
#       Destination AWS Profile
##################################################################################################
ALB_AWS_ACCT_PROFILE="my-profile"
ALB_ENDPOINT="my-alb-123456789.us-east-1.elb.amazonaws.com"
Domain_Array=(abc.example.com xyz.example.com example.com otherexample.com bcd.otherexample.com)
DEST_AWS_PROFILE="my-dest-profile"

# Get ALB ARN
ALB_ARN="$(aws elbv2 describe-load-balancers --region us-east-1 --profile ${ALB_AWS_ACCT_PROFILE} | jq -cr .LoadBalancers[].LoadBalancerArn | grep my-alb)"

# Get ALB HostedZoneId
ALB_HOSTEDZONEID="$(aws elbv2 describe-load-balancers --load-balancer-arns ${ALB_ARN} --region us-east-1 --profile ${ALB_AWS_ACCT_PROFILE} | jq -cr .LoadBalancers[].CanonicalHostedZoneId)"

# Loop through the Array
for i in ${Domain_Array[*]}
do
  MY_SUBDOMAIN="${i}"
  dot_count=
  MY_DOMAIN=
  HOSTEDZONEID=
  
  # Determine if it is main Domain or Subdomain based on the number of Dots in the name.
  dot_count=$(echo ${i} | grep -io '\.' | grep -c .)
  if [[ ${dot_count} == 2 ]]; then
     MY_DOMAIN="$(echo ${i} | cut -d'.' -f2-)"
	 echo "MY_DOMAIN = ${MY_DOMAIN}"
  elif [[ ${dot_count} == 1 ]]; then
     MY_DOMAIN="${i}"
	 MY_SUBDOMAIN="${i}"
  elif [[ ${dot_count} > 2 || ${dot_count} < 1 ]]; then
     echo "NOT valid domain.. \"${i}\" - Skipping.."
     continue
  fi
  
  # Get Destination Route53 HostedZoneId for the Hosted Zone
  if [[ -n ${MY_DOMAIN} ]]; then
     HOSTEDZONEID="$(aws route53 list-hosted-zones-by-name --region us-east-1 --profile ${DEST_AWS_PROFILE} --query 'HostedZones[].{Name:Name,Id:Id}' --output text | grep "${MY_DOMAIN}" | awk '{print $1}' | cut -d/ -f3)"
	 echo "Destination AWS Acct Route 53 HostedZoneId = ${HOSTEDZONEID}"
  else
	 echo "${MY_DOMAIN} - Main Site Domain - is Empty!"
     continue
  fi
  if [[ -z ${HOSTEDZONEID} ]]; then
     echo "${HOSTEDZONEID} - Hosted Zone ID - is Empty!!"
	 continue
  else
     # Create the Batch file for the A Record Alias
     cat > ${MY_SUBDOMAIN}_A_Record_Alias.json <<A_Record_Alias_JSON
{
  "Comment": "Updating Alias Resource Record sets for ${MY_SUBDOMAIN} in Route 53",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${MY_SUBDOMAIN}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "${ALB_HOSTEDZONEID}",
          "DNSName": "${ALB_ENDPOINT}",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
A_Record_Alias_JSON

   # Change Resource RecordSet for the A Record
   aws route53 change-resource-record-sets --hosted-zone-id ${HOSTEDZONEID} --change-batch file://${MY_SUBDOMAIN}_A_Record_Alias.json --region us-east-1 --profile ${DEST_AWS_PROFILE}
   if [[ $? -eq 0 ]]; then
     echo "RecordSet for ${MY_SUBDOMAIN} has been updated "
	 echo "in Hosted Zone - \"${MY_DOMAIN}\" with HostedZoneId = \"${HOSTEDZONEID}\""
   else
     echo "ERROR: An Error occurred creating Resource Record Set for domain - ${MY_SUBDOMAIN}"
   fi
  fi
done
