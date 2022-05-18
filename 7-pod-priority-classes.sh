# Pod Priority Classes

cat <<EoF > critical-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-priority
value: 400
globalDefault: true
description: "critical-priority Pods"
EoF
kubectl apply -f critical-priority-class.yml

cat <<EoF > realtime-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: realtime-priority
value: 300
globalDefault: false
description: "realtime-priority Pods"
EoF
kubectl apply -f realtime-priority-class.yml

cat <<EoF > high-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 200
globalDefault: false
description: "high-priority Pods"
EoF
kubectl apply -f high-priority-class.yml

cat <<EoF > low-priority-class.yml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
globalDefault: false
description: "low-priority Pods"
EoF
kubectl apply -f low-priority-class.yml
