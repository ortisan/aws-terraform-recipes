# user_data.sh

#!/bin/bash
echo ECS_CLUSTER=development >> /etc/ecs/ecs.config
yum update -y