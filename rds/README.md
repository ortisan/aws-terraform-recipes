# RDS

This demo demonstrate how create DB Instance and Aurora RDS, and migrate a snapshot from DB Instance to Aurora.

## Create DB Instance

```sh
cd db_instance
terraform init
terraform apply -auto-approve
```

## Create Aurora

```sh
cd aurora
terraform init
terraform apply -auto-approve
```
