#!/bin/bash

# Update packages
sudo yum update -y
sudo yum install -y ecs-init
sudo service docker start
sudo start ecs

#Adding cluster name in ecs config
echo ECS_CLUSTER=router >> /etc/ecs/ecs.config
