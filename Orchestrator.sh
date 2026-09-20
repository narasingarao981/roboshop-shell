#!/bin/bash

instances=("frontend" "mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping" "rabbitmq" "payment" "dispatch")
AMI_ID="ami-0220d79f3f480ecf5"
SG_GROUP="sg-0f20ff58735ff6cde"
instance_type="t3.micro"
subnet_id="subnet-03389726b7cd3df4e"
CSV_PATH="$PWD/ips.csv"
HOSTED_ZONE_ID="Z04148142KCH92IOUT66N"
DOMAIN_NAME="singamden.fun"

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


#function to create instances and update DNS records
create_instance(){
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --instance-type $instance_type --security-group-ids $SG_GROUP --subnet-id $subnet_id --query 'Instances[0].InstanceId' --output text)
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    
    if [ $1 == "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
        update_dns_route53 $DOMAIN_NAME $IP
        PIP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
        echo "$1 , $PIP" >> "$CSV_PATH"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
        RECORD_NAME="$1.$DOMAIN_NAME"
        update_dns_route53 $RECORD_NAME $IP
        echo "$1 , $IP" >> "$CSV_PATH"
    fi

    
}



: > "$CSV_PATH"

for instance in "${instances[@]}"
do 
    #echo $instance
    create_instance $instance
done