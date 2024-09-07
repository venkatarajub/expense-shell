#!/bin/bash
USERID=$(id -u)

#colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

#Log file structure
LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log

mkdir -p $LOG_FOLDER

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Run the script with root privilages $N" | tee -a $LOG_FILE
        exit 1
    fi 
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is ... $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is ... $G SUCCESS $N" |tee -a $LOG_FILE
    fi
}

CHECK_ROOT

echo -e "$Y Script executed on $(date) $N" | tee -a $LOG_FILE

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysql server"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting mysql  server"
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
VALIDATE $? "Setting root password"