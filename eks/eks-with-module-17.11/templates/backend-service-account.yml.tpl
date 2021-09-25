apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
  namespace: applications
  annotations:
    eks.amazonaws.com/role-arn: ${service_role_arn}
