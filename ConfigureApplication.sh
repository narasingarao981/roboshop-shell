#!/bin/bash

USER="ec2-user"
PASSWD="DevOps321"

# Source - https://stackoverflow.com/a/9587786
# Posted by Benoit, modified by community. See post 'Timeline' for change history
# Retrieved 2026-09-20, License - CC BY-SA 4.0

file="/home/ec2-user/roboshop-shell/ips.csv"
while read line; do
  InstanceName=$(echo "$line" | cut -d "," -f 1)
  IP=$(echo "$line" | cut -d " " -f 2)
  echo $InstanceName
  echo $IP
done < "$file"
