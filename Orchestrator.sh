#!/bin/bash

instances={"frontend" "mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping" "rabbitmq" "payment" "dispatch"}
AMI_ID = 
SG_GROUP = 
instance_type=
subnet_id=

#function to create instances
create_instance(){
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $instance_type --query 'Instances[0].InstanceId' --output text)
    echo "My new instance ID is: $INSTANCE_ID"

}

#function to update DNS records with instance IP addresses
update_dns_route53(){

}

#create a csv file and update the instance internal IP
update_IP_store(){

}

#Connect to VM and clone the git repo and execute the respective script
instance_configure(){

}