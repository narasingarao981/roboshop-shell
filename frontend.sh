#!/bin/bash


echo "Preparing Frontend Component"

rpm -qa | grep nginx-1.24

validate(){
    if [ $1 -eq 0 ]
    then
        echo "$2 executed successfully"
    else
        echo "$2 failed to execute"
        exit 1
    fi
}

if [ $? -ne 0 ]
then 
    sudo dnf module disable nginx -y
    validate $? "nginx module diable"
    dnf module enable nginx:1.24 -y
    validate $? "nginx 1.24 module enable"
    dnf install nginx -y
    validate $? "nginx installation"
    systemctl enable nginx 
    validate $? "nginx auto start"    
    rm -rf /usr/share/nginx/html/* 
    validate $? "Removing the default html files"
    curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
    validate $? "cloning the application"
    cd /usr/share/nginx/html 
    unzip /tmp/frontend.zip
    validate $? "nginx unzip"
    cp /home/ec2-user/roboshop-shell/nginx.conf /etc/nginx/nginx.conf
    validate $? "nginx application file copy"
    systemctl start nginx 
    validate $? "nginx service start"

else
    echo "installation already exists.. SKIPPING"
