#!/bin/bash

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

validate(){
    if [ $1 -eq 0 ]
    then
        echo "$2 executed successfully" | tee -a $LOG_FILE
    else
        echo "$2 failed to execute" | tee -a $LOG_FILE
        exit 1
    fi
}


dnf module disable nginx -y | tee -a $LOG_FILE
validate $? "nginx module diable"
dnf module enable nginx:1.24 -y | tee -a $LOG_FILE
validate $? "nginx 1.24 module enable"
dnf install nginx -y | tee -a $LOG_FILE
validate $? "nginx installation"
systemctl enable nginx | tee -a $LOG_FILE
validate $? "nginx auto start"    
rm -rf /usr/share/nginx/html/* 
validate $? "Removing the default html files"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
validate $? "cloning the application"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip | tee -a $LOG_FILE
validate $? "nginx unzip"
cp /home/ec2-user/roboshop-shell/nginx.conf /etc/nginx/nginx.conf
validate $? "nginx application file copy"
systemctl start nginx | tee -a $LOG_FILE
validate $? "nginx service start"

