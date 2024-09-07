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
        echo -e "$R Run the script with root privilages $N"
        exit 1
    fi 
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 is ... $G SUCCESS $N"
    fi 
}

CHECK_ROOT

echo -e "$Y Script executed on $(date)" | tee -a $LOG_FILE

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disableing defult nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE  $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists.. $G creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user exists.. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "extracting back code"

npm install &>>$LOG_FILE
VALIDATE $? "installing dependence"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copying the backend code"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Mysql claint installing"

mysql -h 172.31.28.10 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "deamon reloading"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enablening backed"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restating backend"


