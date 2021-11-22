# API Gateway

Recipes with API Gateway.

## Lambda Environment

```sh
cd with-lambdas
```

```sh
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

## Package Lambda

```sh
sh make.sh
```

## Create Infra

```sh
terraform init
terraform apply -auto-approve
```

![image](images/apigateway.png)

## Execute API Gateway

![image](images/apigateway-lambda.png)
