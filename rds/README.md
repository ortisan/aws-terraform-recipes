# RDS

This demo demonstrate how create DB Instance and Aurora RDS, and migrate a snapshot from DB Instance to Aurora.

## Create DB Instance

```sh
cd db_instance
terraform init
terraform apply -auto-approve
```

## Fake DB rows

```sh
cd automate/data-generator
conda create -n data-generator python=3.8.8
conda activate data-generator
pip install -r requirements.txt
python generate_inserts.py
```

## Connect to DB Instance and insert rows

```sh
mysql -h <db_instance_endpoint> -u ortisan -portisan123 uuserdb < automate/scripts/1-schema.sql
mysql -h <db_instance_endpoint> -u ortisan -portisan123 uuserdb < automate/scripts/2-inserts.sql
```
## Create snapshot

```sh
aws rds create-db-snapshot \
    --db-instance-identifier userdb \
    --db-snapshot-identifier userdbsnapshot
```

## Create Aurora

Get the ARN of snapshot, and edit **db_instance_snapshot_arn** variable into aurora folder

Create Aurora Cluster from DB Instance snapshot:

```sh
cd aurora
terraform init
terraform apply -auto-approve
```

**IMPORTANT: THIS procedure for restore from mysql 8.3 to Aurora Mysql 5.7 does not work because the major version. I will try from S3 bucket (TODO)**

## Docs:

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Importing.html