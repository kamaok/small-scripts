#!/usr/bin/env bash

# date format
DATE="$(date +"%Y-%m-%d")"

# storage
STORAGEDIR='/backup/mysql'

# user,password,host for mysql connection
MUSER="root"
MPASS="mypassword"
MHOST="localhost"

DATABASE_NAME="mysqllab"
CONTAINER_NAME=$(docker ps | awk '/mysqllab/ {print $1}')

# monitoring errors and success in creating backup
LOGFILE="/var/log/backup-mysql.log"

# how many days should we keep the backups
LIMITTIME="+14"

HOSTNAME="$(hostname -f)"
MAIL_SUBJECT="Backup mysql status on the server $HOSTNAME"
MAIL_TO="myname@mydomain.com"

mailfunction () {
 mail -s "${MAIL_SUBJECT}" ${MAIL_TO}
}

[ ! -d $STORAGEDIR ] && mkdir -p $STORAGEDIR

docker exec ${CONTAINER_NAME} mysqldump -u $MUSER -h $MHOST -p$MPASS -EKR --single-transaction ${DATABASE_NAME} | gzip -c > $STORAGEDIR/${DATABASE_NAME}-$DATE.sql.gz

  if [ ${PIPESTATUS[0]} != "0" ];
    then
  echo "Backup database ${DATABASE_NAME} is failed - $DATE" | mailfunction
    else
  echo "Backup database ${DATABASE_NAME} is done! Backup up to $DATE " | mailfunction
  fi

# delete backups older 14 days
find $STORAGEDIR -maxdepth 1 -type f -name '*.sql.gz' -mtime $LIMITTIME -exec rm -rf {} \;

