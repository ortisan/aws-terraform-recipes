#!/bin/bash

# Update packages
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo yum update -y
sudo yum install -y ecs-init
sudo systemctl enable amazon-ssm-agent 
sudo systemctl start amazon-ssm-agent
sudo service docker start
sudo start ecs

#Adding cluster name in ecs config
echo ECS_CLUSTER=router >> /etc/ecs/ecs.config
