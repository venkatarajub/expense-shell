#!/bin/bash
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log

mkdir -p $LOG_FOLDER

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Run the script with root privilages"
        exit 1
    if
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 is ... $G SUCCESS $N"
}

CHECK_ROOT

echo -e "$Y Script executed on $(date)" | tee -a $LOG_FILE

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disableing defult nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE  $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

useradd expense
VALIDATE $? "adding expense user"