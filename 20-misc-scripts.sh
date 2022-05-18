# Admin Access to k8 for Console view

eksctl create iamidentitymapping \
  --cluster ${CLUSTER_NAME} \
  --arn arn:aws:iam::145454557612:role/testAcc2Admin \
  --username admin \
  --group system:masters

# Simple Job Submission
export CURRENT_VIRTUAL_CLUSTER=nightly-batch-emr-cluster
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='${CURRENT_VIRTUAL_CLUSTER}' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text)

cat > emr-request-withlogging.json <<EOF 
{
    "name": "pi-4",
    "virtualClusterId": "${VIRTUAL_CLUSTER_ID}",
    "executionRoleArn": "$(aws iam get-role --role-name nightly-batch-JobExecutionRole --query Role.Arn --output text)",
    "releaseLabel": "emr-6.2.0-latest",
    "jobDriver": {
        "sparkSubmitJobDriver": {
            "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
            "sparkSubmitParameters": " --conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
        }
    },
    "configurationOverrides": {
        "applicationConfiguration": [
            {
                "classification": "spark-defaults",
                "properties": {
                  "spark.dynamicAllocation.enabled": "false",
                  "spark.kubernetes.executor.deleteOnTermination": "true"
                }
            }
        ],
        "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
                "logGroupName": "/emr-on-eks/${CLUSTER_NAME}/nightly-batch",
                "logStreamNamePrefix": "pi"
            }, 
"s3MonitoringConfiguration": { 
"logUri": "s3://${CURRENT_VIRTUAL_CLUSTER}-${AWS_ACCOUNT_ID}-${AWS_REGION}/" 
}

        }
    }
}
EOF

aws emr-containers start-job-run --cli-input-json file://emr-request-withlogging.json
