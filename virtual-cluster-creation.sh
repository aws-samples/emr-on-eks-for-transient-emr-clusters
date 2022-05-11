# EKS Namespaces for process isoloation in EKS. 
kubectl create namespace realtime-batch
kubectl create namespace intra-day-batch
kubectl create namespace nightly-batch
kubectl create namespace monthly-batch
kubectl create namespace adhoc-ml-batch



# Register EKS cluster with EMR
# The final step is to register EKS cluster with EMR.

aws emr-containers create-virtual-cluster \
--name realtime-batch-emr-cluster \
--container-provider '{
    "id": "eks-emr-cluster",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "realtime-batch"
        }
    }
}'

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
}'

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
}'

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
}'

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
}'
