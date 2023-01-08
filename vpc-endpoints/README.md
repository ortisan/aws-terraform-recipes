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

List endpoints

```sh
aws ec2 describe-vpc-endpoint-services --region us-east-1
```

Connect to Bastion and make calls to S3

```sh
aws s3 ls
```

Describe instance

```sh
aws ec2 describe-instances --instance-ids i-0c5d1b5041ca419ef --region us-east-1
```

Show all tables

```sh
aws dynamodb list-tables --region us-east-1
```


## Docs:

https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html

