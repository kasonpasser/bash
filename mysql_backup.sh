#!/bin/sh
# mysql_backup.sh: backup mysql databases and keep newest 30 days backup.
# -----------------------------
db_host="127.0.0.1"
db_user="root"
db_passwd='123123'
db_port="3360"

# backup directory name
now_day="$(date +"%Y%m%d")"
# delete old backup directory  (30 day)
day_old="$(date -d "-30 day" "+%Y%m%d")"

# don't backup database
exarr_db=(mysql performance_schema information_schema test)

# the directory for story your backup file.
backup_dir="/data/backup/"
# date format for backup file (dd-mm-yyyy)
time="$(date +"%d-%m-%Y")"

# mysql, mysqldump and some other bins path
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"

# system cmd
MKDIR="/bin/mkdir"
RM="/bin/rm"
MV="/bin/mv"
GZIP="/bin/gzip"

# check the directory for store backup is writeable
test ! -w $backup_dir && echo "Error: $backup_dir is un-writeable." && exit 0
# the directory for story the newest backup
test ! -d "$backup_dir/$now_day/" && $MKDIR "$backup_dir/$now_day/"

# get all databases
all_db="$($MYSQL -u$db_user -h$db_host -P$db_port -p$db_passwd -Bse 'show databases')"
for db in $all_db
do
	for exdb in ${exarr_db[@]}
	do
		if [ "$db"_ = "$exdb"_ ];then
			db="_$db"
		fi
	done

	if [[ $db == _* ]]; then
		a="a"
	else
		$MYSQLDUMP -u$db_user -h$db_host -P$db_port -p$db_passwd $db --skip-add-locks | $GZIP -9 > "$backup_dir/$now_day/$db.gz"
	fi
done

# delete the oldest backup
test -d "$backup_dir/$day_old/" && $RM -rf "$backup_dir/$day_old"

echo "Successed!"
exit 0;

