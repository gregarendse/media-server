---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: {{ include "server.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "server.labels" . | nindent 4 }}

spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "server.fullname" . }}
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: {{ .Release.Name }}
      maxAllowed:
        cpu: 8
        memory: 16Gi
      minAllowed:
        cpu: 10m
        memory: 16Mi