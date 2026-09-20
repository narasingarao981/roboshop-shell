#!/bin/bash

instances=( "frontend" "mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping" "rabbitmq" "payment" "dispatch" )
AMI_ID = "ami-0220d79f3f480ecf5"
SG_GROUP = "sg-0f20ff58735ff6cde"
instance_type= "t3.micro"
subnet_id= "subnet-03389726b7cd3df4e"
PATH=$PWD
HOSTED_ZONE_ID = "Z04148142KCH92IOUT66N"
DOMAIN_NAME= "singamden.fun"

if [ -d "$PATH/ips.csv" ]
then 
    rm -rf "$PATH/ips.csv"
    touch "$PATH/ips.csv"
    chmod 777 "$PATH/ips.csv"
else
    touch "$PATH/ips.csv"
    chmod 777 "$PATH/ips.csv"
fi

for instance in Instances 
do 
    create_instance instance

done

#function to create instances and update DNS records
create_instance(){
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --instance-type $instance_type --security-group-ids $SG_GROUP --subnet-id subnet-xxxxxxxx--query 'Instances[0].InstanceId' --output text)
    
    if [ $1 -eq "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
        update_dns_route53 $RECORD_NAME $IP
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
        update_dns_route53 $RECORD_NAME $IP
    fi
    
}

#function to update DNS records with instance IP addresses
update_dns_route53(){

    aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '{
    "Comment": "Updating A record IP",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$1'",
          "Type": "A",
          "TTL": 60,
          "ResourceRecords": [
            {
              "Value": "'$2'"
            }
          ]
        }
      }
    ]
  }'

}

#create a csv file and update the instance internal IP
update_IP_store(){

}

#Connect to VM and clone the git repo and execute the respective script
instance_configure(){

}