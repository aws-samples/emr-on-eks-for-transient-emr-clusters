## ServiceName Mapping with RBAC (Role & Rolebinding)
# RBAC permissions and for adding EMR on EKS service-linked role into aws-auth configmap

eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace realtime-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace intra-day-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace nightly-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace monthly-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace adhoc-ml-batch --service-name "emr-containers"


#Enable IAM Roles for Service Account (IRSA)
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve

#Create IAM Role for job execution

#Trust Policy for EMR
cat <<EoF > ~/environment/emr-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EoF
# Creating Role with Trust Policy
aws iam create-role --role-name realtime-batch-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json
aws iam create-role --role-name intra-day-batch-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json
aws iam create-role --role-name nightly-batch-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json
aws iam create-role --role-name monthly-batch-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json
aws iam create-role --role-name adhoc-ml-batch-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json

# Policy For s3 & Cloud Watch
cat <<EoF > ~/environment/EMRContainers-JobExecutionRole.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}  
EoF

# Attach log policy to Execution Roles
aws iam put-role-policy --role-name realtime-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json
aws iam put-role-policy --role-name intra-day-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json
aws iam put-role-policy --role-name nightly-batch-JobExecutionRole  --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json
aws iam put-role-policy --role-name monthly-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json
aws iam put-role-policy --role-name adhoc-ml-batch-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json

# Update trust relationship for job execution role - (Between IAM Roles & EMR Service Identity)
aws emr-containers update-role-trust-policy --cluster-name ${CLUSTER_NAME} --namespace realtime-batch --role-name realtime-batch-JobExecutionRole
aws emr-containers update-role-trust-policy --cluster-name ${CLUSTER_NAME} --namespace intra-day-batch --role-name intra-day-batch-JobExecutionRole
aws emr-containers update-role-trust-policy --cluster-name ${CLUSTER_NAME} --namespace nightly-batch --role-name nightly-batch-JobExecutionRole
aws emr-containers update-role-trust-policy --cluster-name ${CLUSTER_NAME} --namespace monthly-batch --role-name monthly-batch-JobExecutionRole
aws emr-containers update-role-trust-policy --cluster-name ${CLUSTER_NAME} --namespace adhoc-ml-batch --role-name adhoc-ml-batch-JobExecutionRole
