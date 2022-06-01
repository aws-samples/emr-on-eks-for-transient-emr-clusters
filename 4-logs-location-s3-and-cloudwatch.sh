# Create CloudWatch logs location
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/realtime-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/intra-day-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/nightly-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/monthly-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/adhoc-ml-batch

# Create S3 bucket for logs (Optinal and for long term retension)

aws s3 mb s3://realtime-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 mb s3://intra-day-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 mb s3://nightly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 mb s3://monthly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 mb s3://adhoc-ml-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION}

