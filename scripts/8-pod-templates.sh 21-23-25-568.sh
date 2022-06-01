## EMR  Pod Templates (Optional - for Prority based use cases)

# Spark Driver Template
cat > spark_driver_pod_template.yml <<EOF 
apiVersion: v1
kind: Pod
spec:
  priorityClassName: "critical-priority"
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  nodeSelector:
    eks.amazonaws.com/capacityType: ON_DEMAND
  containers:
  - name: spark-kubernetes-driver # This will be interpreted as Spark driver container
EOF


# Spark Executor template for high priority &/ time critical jobs
cat > hp_spark_executor_pod_template.yml <<EOF 
apiVersion: v1
kind: Pod
spec:
  # Reusing the critical priority class
  priorityClassName: "critical-priority"
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  nodeSelector:
    eks.amazonaws.com/capacityType: ON_DEMAND
  containers:
  - name: spark-kubernetes-executor # This will be interpreted as Spark executor container
EOF


# Spark Executor template for low priority jobs
cat > lp_spark_executor_pod_template.yml <<EOF 
apiVersion: v1
kind: Pod
spec:
  priorityClassName: "low-priority"
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  containers:
  - name: spark-kubernetes-executor # This will be interpreted as Spark executor container
EOF

# S3 Template Location
export POD_TEMPLATE_PATH="s3://${CLUSTER_NAME}-pod-templates-${AWS_ACCOUNT_ID}-${AWS_REGION}"
aws s3 mb $POD_TEMPLATE_PATH
aws s3 cp spark_driver_pod_template.yml $POD_TEMPLATE_PATH
aws s3 cp hp_spark_executor_pod_template.yml $POD_TEMPLATE_PATH
aws s3 cp lp_spark_executor_pod_template.yml $POD_TEMPLATE_PATH

echo $POD_TEMPLATE_PATH
