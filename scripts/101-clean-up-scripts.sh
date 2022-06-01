
eksctl delete iamidentitymapping \
    --cluster ${CLUSTER_NAME} \
    --region=${AWS_REGION} \
    --arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${MY_EKSCONSOLE_ROLE} \

kubectl delete -f https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml


# unInstall karpenter
helm uninstall --namespace karpenter karpenter
aws iam delete-role --role-name "${CLUSTER_NAME}-karpenter"
aws cloudformation delete-stack --stack-name "Karpenter-${CLUSTER_NAME}"


# Clean up S3 Folder for Demo JObs Templates.
export DEMO_JOBS_PATH=s3://${CLUSTER_NAME}-demojobs-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 rm $DEMO_JOBS_PATH  --recursive
aws s3 rb $DEMO_JOBS_PATH --force



# Clean up S3 Folder for Pod Templates.
export POD_TEMPLATE_PATH=s3://${CLUSTER_NAME}-pod-templates-${AWS_ACCOUNT_ID}-${AWS_REGION}
aws s3 rm $POD_TEMPLATE_PATH  --recursive
aws s3 rb $POD_TEMPLATE_PATH --force



# Delete CloudWatch logs location
aws logs delete-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/realtime-batch
aws logs delete-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/intra-day-batch
aws logs delete-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/nightly-batch
aws logs delete-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/monthly-batch
aws logs delete-log-group --log-group-name=/emr-on-eks/${CLUSTER_NAME}/adhoc-ml-batch

# Delete logs from S3 bucket
aws s3 rm s3://realtime-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive
aws s3 rm s3://intra-day-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive
aws s3 rm s3://nightly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive
aws s3 rm s3://monthly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive
aws s3 rm s3://adhoc-ml-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive

# Delete S3 bucket
aws s3 rb s3://realtime-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --force
aws s3 rb s3://intra-day-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --force
aws s3 rb s3://nightly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --force
aws s3 rb s3://monthly-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --force
aws s3 rb s3://adhoc-ml-batch-logs-${AWS_ACCOUNT_ID}-${AWS_REGION} --force


# Deleting job execution roles and policies
aws iam delete-role-policy --role-name realtime-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name realtime-batch-JobExecutionRole 

aws iam delete-role-policy --role-name intra-day-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name intra-day-batch-JobExecutionRole

aws iam delete-role-policy --role-name nightly-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name nightly-batch-JobExecutionRole

aws iam delete-role-policy --role-name monthly-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name monthly-batch-JobExecutionRole

aws iam delete-role-policy --role-name adhoc-ml-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name adhoc-ml-batch-JobExecutionRole


# Deleting EMR virtual clusters
aws emr-containers delete-virtual-cluster \
--id $(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='realtime-batch-emr-cluster' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text) \
--no-cli-pager

aws emr-containers delete-virtual-cluster \
--id $(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='intra-day-batch-emr-cluster' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text) \
--no-cli-pager

aws emr-containers delete-virtual-cluster \
--id $(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='nightly-batch-emr-cluster' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text) \
--no-cli-pager

aws emr-containers delete-virtual-cluster \
--id $(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='monthly-batch-emr-cluster' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text) \
--no-cli-pager

aws emr-containers delete-virtual-cluster \
--id $(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='adhoc-ml-batch-emr-cluster' && state=='RUNNING' && containerProvider.id=='${CLUSTER_NAME}'].id" --output text) \
--no-cli-pager

# Deleting EKS namesapces 
# * Deletes roles and rolebinding along with it
kubectl delete namespace realtime-batch
kubectl delete namespace intra-day-batch
kubectl delete namespace nightly-batch
kubectl delete namespace monthly-batch
kubectl delete namespace adhoc-ml-batch

# Detaching CloudWatchAgentServerPolicy from 
STACK_NAME=$(eksctl get nodegroup --cluster ${CLUSTER_NAME} -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

# Deleting Instance Role 
INSTANCE_PROFILE=$(aws iam list-instance-profiles-for-role --role-name $ROLE_NAME | jq -r '.InstanceProfiles[].InstanceProfileName')

aws iam remove-role-from-instance-profile --instance-profile-name $INSTANCE_PROFILE --role-name $ROLE_NAME
aws iam delete-instance-profile --instance-profile-name $INSTANCE_PROFILE

aws iam delete-role --role-name ${ROLE_NAME}


#Deleting the Cluster
eksctl delete cluster --name=${CLUSTER_NAME}




