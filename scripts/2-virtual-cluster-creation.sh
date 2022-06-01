# EKS Namespaces for process isoloation in EKS. 
kubectl create namespace realtime-batch
kubectl create namespace intra-day-batch
kubectl create namespace nightly-batch
kubectl create namespace monthly-batch
kubectl create namespace adhoc-ml-batch


## ServiceName Mapping with RBAC (Role & Rolebinding)
# RBAC permissions and for adding EMR on EKS service-linked role into aws-auth configmap

eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace realtime-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace intra-day-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace nightly-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace monthly-batch --service-name "emr-containers"
eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --namespace adhoc-ml-batch --service-name "emr-containers"


#Enable IAM Roles for Service Account (IRSA)
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve

# Register EKS cluster with EMR
# The final step is to register EKS cluster with EMR.

aws emr-containers create-virtual-cluster \
--name realtime-batch-emr-cluster \
--container-provider '{
    "id": "'"${CLUSTER_NAME}"'",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "realtime-batch"
        }
    }
}' \
--no-cli-pager

aws emr-containers create-virtual-cluster \
--name intra-day-batch-emr-cluster \
--container-provider '{
    "id": "eks-emr-cluster",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "intra-day-batch"
        }
    }
}' \
--no-cli-pager

aws emr-containers create-virtual-cluster \
--name nightly-batch-emr-cluster \
--container-provider '{
    "id": "eks-emr-cluster",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "nightly-batch"
        }
    }
}' \
--no-cli-pager

aws emr-containers create-virtual-cluster \
--name monthly-batch-emr-cluster \
--container-provider '{
    "id": "eks-emr-cluster",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "monthly-batch"
        }
    }
}' \
--no-cli-pager

aws emr-containers create-virtual-cluster \
--name adhoc-ml-batch-emr-cluster \
--container-provider '{
    "id": "eks-emr-cluster",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "adhoc-ml-batch"
        }
    }
}' \
--no-cli-pager