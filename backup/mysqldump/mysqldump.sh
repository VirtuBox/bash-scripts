#!/bin/bash


# -------------------------------------------------------------------------
# Modified First By: Mitesh Shah
# Then Modified By : VirtuBox
# Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------

# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
	exit $2
}


### Set Bins Path ###
RM=/bin/rm
GZIP=/bin/gzip
GREP=/bin/grep
MKDIR=/bin/mkdir
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin
FIND=/usr/bin/find

### Enable Log = 1 ###
LOGS=1

### Default Time Format ###
TIME_FORMAT='%d-%b-%Y-%H%M%S'

### Setup Dump And Log Directory ###
MYSQLDUMPPATH=/var/www/mysqldump
MYSQLFULLDUMPPATH=/var/www/mysqldump/full
MYSQLDUMPLOG=/var/log/mysqldump.log
EXTRA_PARAMS=$1

### Remove Backup older than X days ###
DAYSOLD=3

### Backup all-databases in a single file ###
ALLDB=0

#####################################
### ----[ No Editing below ]------###
#####################################

[ -f ~/.my.cnf ] || error "Error: ~/.my.cnf not found"

### Make Sure Bins Exists ###
verify_bins(){
	[ ! -x $GZIP ] && error "File $GZIP does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQL ] && error "File $MYSQL does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLDUMP ] && error "File $MYSQLDUMP does not exists. Make sure correct path is set in $0."
	[ ! -x $RM ] && error "File $RM does not exists. Make sure correct path is set in $0."
	[ ! -x $MKDIR ] && error "File $MKDIR does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLADMIN ] && error "File $MYSQLADMIN does not exists. Make sure correct path is set in $0."
	[ ! -x $GREP ] && error "File $GREP does not exists. Make sure correct path is set in $0."
	[ ! -x $FIND ] && error "File $GREP does not exists. Make sure correct path is set in $0."
}


### Make Sure We Can Connect To The Server ###
verify_mysql_connection(){
	$MYSQLADMIN  ping | $GREP 'alive' > /dev/null
	[ $? -eq 0 ] || error "Error: Cannot connect to MySQL Server. Make sure username and password are set correctly in $0"
}


### Make A Backup ###
backup_mysql(){
	local DBS="$($MYSQL -Bse 'show databases')"
	local db="";

	[ ! -d $MYSQLDUMPLOG ] && $MKDIR -p $MYSQLDUMPLOG
	[ ! -d $MYSQLDUMPPATH ] && $MKDIR -p $MYSQLDUMPPATH
    
	# find backup older than $DAYOLD and remove them
	$FIND $MYSQLDUMPPATH -type f -mtime +$DAYSOLD -exec $RM -f {} \;  &>> $MYSQLDUMPLOG/mysqldump.log

	[ $LOGS -eq 1 ] && echo "" &>> $MYSQLDUMPLOG/mysqldump.log
	[ $LOGS -eq 1 ] && echo "*** Dumping MySQL Database At $(date) ***" &>> $MYSQLDUMPLOG/mysqldump.log
	[ $LOGS -eq 1 ] && echo "Database >> " &>> $MYSQLDUMPLOG/mysqldump.log

	for db in $DBS
	do
		local TIME=$(date +"$TIME_FORMAT")
		local FILE="$MYSQLDUMPPATH/$db/$db.$TIME.gz"
		[ $LOGS -eq 1 ] && echo -e \\t "$db" &>> $MYSQLDUMPLOG/mysqldump.log

		if [  $db = "mysql" ] || [  $db = "performance_schema" ] || [  $db = "slow_query_log" ] || [  $db = "information_schema" ] || [  $db = "phpmyadmin" ]
		then
			echo "mysql settings tables" &>> $MYSQLDUMPLOG/mysqldump.log
		else
        	[ ! -d $MYSQLDUMPPATH/$db ] && $MKDIR -p $MYSQLDUMPPATH/$db
			$MYSQLDUMP --single-transaction --skip-lock-tables $db $EXTRA_PARAMS | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed $db"
		fi
	done

    
	[ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLDUMPPATH] ***" &>> $MYSQLDUMPLOG/mysqldump.log
}

## Backup all databases 
backup_mysql_all_database(){

	[ $LOGS -eq 1 ] && echo "" &>> $MYSQLDUMPLOG/mysqldump.log
	[ $LOGS -eq 1 ] && echo "*** Dumping MySQL all-database At $(date) ***" &>> $MYSQLDUMPLOG/mysqldump.log
	    
    local TIME=$(date +"$TIME_FORMAT")
    [ ! -d $MYSQLFULLDUMPPATH ] && $MKDIR -p $MYSQLFULLDUMPPATH
    local FILE="$MYSQLDUMPPATH/all-database.$TIME.gz"
    $MYSQLDUMP --all-databases --single-transaction --skip-lock-tables | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed all-databases"

	[ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLDUMPPATH] ***" &>> $MYSQLDUMPLOG/mysqldumpl.log
}


### Main ####
verify_bins
verify_mysql_connection
backup_mysql
if [  $ALLDB = "1" ]; then
backup_mysql_all_database
fi
