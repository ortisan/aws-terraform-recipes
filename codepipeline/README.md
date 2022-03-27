# CodePipeline

Create a pipeline with blue/green canary deployment.

Based on: https://docs.aws.amazon.com/pt_br/codepipeline/latest/userguide/tutorials-ecs-ecr-codedeploy.html#tutorials-ecs-ecr-codedeploy-imagerepository

#### Docs:
https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html


#### ECR Upload image:

  ```sh
  docker pull nginx
  aws ecr create-repository --repository-name nginx
  docker tag nginx:latest 779882487479.dkr.ecr.us-east-1.amazonaws.com/nginx:latest
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 779882487479.dkr.ecr.us-east-1.amazonaws.com/nginx
  docker push 779882487479.dkr.ecr.us-east-1.amazonaws.com/nginx:latest
  ```

#### Configuring Codecommit:
https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html#setting-up-ssh-unixes-keys

**Important:** Read **files-to-code-commit/Readme.md**