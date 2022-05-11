# CloudWatch Logs - Create Location
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/realtime-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/intra-day-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/nightly-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/monthly-batch
aws logs create-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/adhoc-ml-batch

# S3 Logs (Optinal and for long term retension) - Create Location

aws s3 mb $realtime-batch-logs
aws s3 mb $intra-day-batch-logs
aws s3 mb $nightly-batch-logs
aws s3 mb $monthly-batch-logs
aws s3 mb $adhoc-ml-batch-logs
