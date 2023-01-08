# VPC Endpoints

Provides private access and lower latency and costs to AWS Resources.

## Pre reqs.

### Environment

Into variable.tf file, change values of region, subnets and allowed security groups of rds.

```sh
terraform init
terraform apply -auto-approve
```


## Testing

Connect to Bastion and make calls to S3

```sh
terraform init
terraform apply -auto-approve
```


## Docs:

https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html

