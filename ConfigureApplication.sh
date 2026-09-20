#!/bin/bash

USER="ec2-user"
PASSWD="DevOps321"
file="/home/ec2-user/roboshop-shell/ips.csv"

#1.reads the instance IPs
#2.Connect to the Instance with the IP and credentials
#3.Execute the respective script
while read line; do

  InstanceName=$(echo "$line" | cut -d " " -f 1)
  IP=$(echo "$line" | cut -d " " -f 3)
  script="$InstanceName.sh"

  echo "Connecting to $InstanceName"
  sshpass -p "$PASSWD" ssh -o StrictHostKeyChecking=no $USER@$IP "[ ! -d 'roboshop-shell' ] && git clone https://github.com/narasingarao981/roboshop-shell.git;cd /home/ec2-user/roboshop-shell;sudo sh $script" < /dev/null

done < "$file"