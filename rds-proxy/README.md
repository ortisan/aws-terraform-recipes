# RDS Proxy

Use RDS Proxy to consume RDS to control pool of connections into lambda environment..

## Pre reqs.

## Environment

Into variable.tf file, change values of region, subnets and allowed security groups of rds.

```sh
terraform init
terraform apply -auto-approve
```

### Docs:

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html
