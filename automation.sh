#!/bin/bash


#Declare Variable
myname="shashi"
s3_bucket="upgrad-$myname"
mytar="$myname-httpd-logs-$(date '+%d%m%Y-%H%M%S')"

#Step-1 Perform an update of the package details and the package list at the start of the script

echo "updating the package details" &&
sudo apt update -y > /dev/null &&

#Step2- Install the apache2 package if it is not already installed

echo "Check if Apache is installed"
dpkg -p "apache2" > /dev/null 2>&1

if [ $? != 0 ]; then
    echo "Apache2 is not installed"
    echo "Apache2 installing"
    sudo apt-get -y install apache2 > /dev/null 2>&1
    echo "Apache2 installed"
else
    echo "Apache2 is already installed"
fi

#Step-3 Ensure that the apache2 service is running.

sudo systemctl status apache2 > /dev/null

if [ $? !=  0 ]
then
     echo "Start apache Server"
     sudo systemctl start apache2.service
else
     echo "Apache server is running now"
fi

#Step-4 Ensure that the apache2 service is Enabled.

sudo systemctl status apache2.service > /dev/null

if [ $? !=  0 ]
then
     echo "Enabling service"
     sudo systemctl enable apache2
else
     echo "Apache Service is enabled now"
fi

#Step-5 Create tar archive of apache2 access logs and error logs and move from /var/logs/apache2 to /tmp
#The name of tar archive should have following format:  <your _name>-httpd-logs-<timestamp>.tar. For example: Ritik-httpd-logs-01212021-101010.tar                  

echo "Create tar file of the log files" &&
tar -cvzf /tmp/$mytar.tar  /var/log/apache2/error.log /var/log/apache2/access.log &&


#Step-6.1 The script should run the AWS CLI command and copy the archive to the s3 bucket.

aws --version > /dev/null

if [ $? !=  0 ]
then
        sudo apt update > /dev/null &&
        sudo apt install awscli > /dev/null
else
        echo "Awscli is already installed"
fi

#Step-6.2 Copy the archive to the S3 bucket

echo "Copy Tar file to S3 bucket" &&
aws s3 cp /tmp/$mytar.tar s3://$s3_bucket/$mytar.tar
