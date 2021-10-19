# Lambda with EventBridge

This example has a lambda that connect throught Google Finance and scrape the Bitcoin price now.

The lambda is triggered by [EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html) every minute.

## Lambda Environment

```sh
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

## Package Lambda

```sh
sh make.sh
```

## Terraform

Provisioning infra:

```sh
terraform apply -auto-approve
```

Destroying infra:

```sh
terraform destroy -auto-approve
```
