# DMS

Use DMS for data migration.

## Pre reqs.

For this recipe, you neeed to have a DB Instance RDS (Source) and an Aurora Mysql RDS (Target).

Follow the [RDS instructions](https://github.com/ortisan/aws-terraform-recipes/tree/main/rds/README.md) to provisione RDS DB Instance(Source) and Aurora Cluster(target).

## Environment

Into variable.tf file, change values of region, connections of source and target endpoints and security infos like security group and if you need KMS.

```sh
terraform init
terraform apply -auto-approve
```

After starting task, the entire **userdb schema** will be migrate from DB Instance to Aurora:

Starting task:
![image](images/dms-start.png)

Result:
![image](images/dms-result.png)

### Docs:

https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Introduction.HighLevelView.html
