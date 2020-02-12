#!/bin/bash

source ./aws_ask_file

# Get CodePipeline ARNs which has DEV and CP in the CodePipeline Name.
# Replacing last char with a *
# Adding a quote " at the end of all the lines
# Adding a comma at the end of all the lines except the last line in the result.
get_dev_CP_ARNs()
{
  aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ${REG} ${PRO} | jq .StackSummaries[].StackId | grep DEV | grep CP | sed -e 's/.$/\/\*/g' -e 's/$/"/g' -e '$!s/$/,/'
}

ask_region
ask_profile

cat > temp.json <<DEV_ADDT_PERM_JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "one",
      "Effect": "Allow",
      "Action": [
        "codepipeline:GetPipeline",
        "codepipeline:GetPipelineState",
        "codepipeline:GetPipelineExecution",
        "codepipeline:ListPipelineExecutions",
        "codepipeline:ListActionTypes",
        "codepipeline:ListPipelines",
        "codepipeline:StartPipelineExecution",
        "cloudformation:CancelUpdateStack",
        "cloudformation:UpdateStackInstances",
        "cloudformation:ListStackInstances",
        "cloudformation:DescribeStackResource",
        "cloudformation:CreateChangeSet",
        "cloudformation:CreateStackInstances",
        "cloudformation:DeleteChangeSet",
        "cloudformation:ContinueUpdateRollback",
        "cloudformation:DescribeStackEvents",
        "cloudformation:UpdateStack",
        "cloudformation:DescribeChangeSet",
        "cloudformation:CreateStackSet",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:ListStackResources",
        "cloudformation:DescribeStackInstance",
        "cloudformation:DescribeStackResources",
        "cloudformation:DescribeStacks",
        "cloudformation:GetStackPolicy",
        "cloudformation:CreateStack",
        "cloudformation:GetTemplate",
        "cloudformation:ListChangeSets"
      ],
      "Resource": [
        $(get_dev_CP_ARNs)
      ]
    },
    {
      "Sid": "two",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateUploadBucket",
        "cloudformation:EstimateTemplateCost",
        "cloudformation:ListExports",
        "cloudformation:ListStacks",
        "cloudformation:ListImports",
        "cloudformation:GetTemplateSummary",
        "cloudformation:ValidateTemplate"
      ],
      "Resource": "*"
    }
  ]
}

DEV_ADDT_PERM_JSON

cat temp.json | jq . > dev-additional-permissions.json
rm temp.json
#cat dev-additional-permissions.json
aws iam put-group-policy --group-name Developers --policy-document file://dev-additional-permissions.json --policy-name dev-additional-permissions $PRO
