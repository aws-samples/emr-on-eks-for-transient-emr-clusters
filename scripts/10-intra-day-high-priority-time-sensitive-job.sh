# Sample Job S3 Location
export DEMO_JOBS_PATH=s3://${CLUSTER_NAME}-demojobs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 mb $DEMO_JOBS_PATH

# Sample Job
cat << EOF > high-priority-threadsleeper.py
import sys
from time import sleep
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("intra-day-high-priority-time-sensitive-job").getOrCreate()

def sleep_for_x_seconds(x):sleep(x*20)

sc=spark.sparkContext
sc.parallelize(range(1,6), 5).foreach(sleep_for_x_seconds)

spark.stop()

EOF

aws s3 cp high-priority-threadsleeper.py ${DEMO_JOBS_PATH}


# Job Submission
export CURRENT_VIRTUAL_CLUSTER=intra-day-batch-emr-cluster
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='${CURRENT_VIRTUAL_CLUSTER}' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text)
${EMR_ROLE_ARN}
export POD_TEMPLATE_PATH=s3://${CLUSTER_NAME}-pod-templates-${AWS_ACCOUNT_ID}-${AWS_REGION}

aws emr-containers start-job-run \
--no-cli-pager \
--virtual-cluster-id ${VIRTUAL_CLUSTER_ID} \
--name intra-day-high-priority-time-sensitive-job \
--execution-role-arn "$(aws iam get-role --role-name intra-day-batch-JobExecutionRole --query Role.Arn --output text)" \
--release-label emr-6.4.0-latest \
--job-driver '{
    "sparkSubmitJobDriver": {
        "entryPoint": "'${DEMO_JOBS_PATH}'/high-priority-threadsleeper.py",
        "sparkSubmitParameters": "--conf spark.kubernetes.driver.podTemplateFile=\"'${POD_TEMPLATE_PATH}'/spark_driver_pod_template.yml\" --conf spark.kubernetes.executor.podTemplateFile=\"'${POD_TEMPLATE_PATH}'/hp_spark_executor_pod_template.yml\" --conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=1 --conf spark.driver.cores=1"
        }
}' \
--configuration-overrides='{
    "applicationConfiguration": [
    {
        "classification": "spark-defaults",
        "properties": {
            "spark.dynamicAllocation.enabled":"false",
            "spark.kubernetes.executor.deleteOnTermination": "true"
        }
    }],
    "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
                "logGroupName": "/emr-on-eks/'${CLUSTER_NAME}'/intra-day-batch",
                "logStreamNamePrefix": "high-p-"
            }, 
            "s3MonitoringConfiguration": { 
            "logUri": "s3://intra-day-batch-logs-'${AWS_ACCOUNT_ID}-${AWS_REGION}'/" 
            }

        }
}'

