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

### Set Bins Path ###
RM=/bin/rm
GZIP=/bin/gzip
GREP=/bin/grep
MKDIR=/bin/mkdir
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin
FIND=/usr/bin/find
PIGZ=/usr/bin/pigz

### Enable Log = 1 ###
LOGS=1

### Default Time Format ###
TIME_FORMAT='%d-%b-%Y-%H%M%S'

### Setup Dump And Log Directory ###
MYSQLDUMPPATH=/var/www/mysqldump
MYSQLFULLDUMPPATH=$MYSQLDUMPPATH/full
MYSQLDUMPLOG=/var/log/mysqldump.log

### Remove Backup older than X days ###
DAYSOLD=3

### Backup all-databases in a single file ###
ALLDB=0
SINGLE_DB=1

### Add help menu
_help() {
    echo "Backup MySQL databases using mysqldump"
    echo "Usage: ./mysqldump.sh [mode][options] ..."
    echo "  Options:"
    echo "       -e, --extra <extra-params> ..... add options to mysqldump command"
    echo "       -p, --path <path> ....... set MySQL dump path"
    echo "       --log <path> ..... set mysqldump.sh log path"
    echo "  Modes:"
    echo "       --full ..... enable all-databases dump in a single file"
    echo "       --only-full ..... enable all-databases dump and disable individual dump"
    echo "  Other options:"
    echo "       -h, --help, help ... displays this help information"
    echo ""
    return 0
}

#####################################
### ----[ No Editing below ]------###
#####################################

# script arguments parsing

while [ "$#" -gt 0 ]; do
    case "$1" in
        -e | --extra)
            EXTRA_PARAMS=$2
            shift
        ;;
        -p | --path)
            MYSQLDUMPPATH=$2
            shift
        ;;
        --log)
            MYSQLDUMPLOG=$2
            shift
        ;;
        -f | --full)
            ALLDB=1
        ;;
        --only-full)
            ALLDB=1
            SINGLE_DB=0
        ;;
        -h | --help | help)
            _help
        ;;
        *) # positional args
        ;;
    esac
    shift
done

### Check if /usr/bin/pigz is executable
### if yes, use pigz instead of gzip to compress with multithreading support

if [ -x $PIGZ ]; then
    COMPRESS=$PIGZ
    NCPU=$(nproc)
    GZIP_ARG="-9 -p$NCPU"
else
    COMPRESS=$GZIP
    GZIP_ARG="-1"
fi

### Make Sure Bins Exists ###
verify_bins() {
    [ ! -x $GZIP ] && {
        echo "File $GZIP does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $MYSQL ] && {
        echo "File $MYSQL does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $MYSQLDUMP ] && {
        echo "File $MYSQLDUMP does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $RM ] && {
        echo "File $RM does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $MKDIR ] && {
        echo "File $MKDIR does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $MYSQLADMIN ] && {
        echo "File $MYSQLADMIN does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $GREP ] && {
        echo "File $GREP does not exists. Make sure correct path is set in $0."
        exit 0
    }
    [ ! -x $FIND ] && {
        echo "File $GREP does not exists. Make sure correct path is set in $0."
        exit 0
    }
}

### Check if .my.cnf exit or if Plesk is installed
if [ ! -f ~/.my.cnf ] && [ ! -d /etc/psa ]; then
    echo "Error: ~/.my.cnf not found"
    exit 0
fi

### Make Sure We Can Connect To The Server ###
verify_mysql_connection() {
    if [ -d /etc/psa ]; then
        MYSQL_PWD=$(cat /etc/psa/.psa.shadow) $MYSQLADMIN -uadmin ping | $GREP 'alive' >/dev/null
    else
        $MYSQLADMIN ping | $GREP 'alive' >/dev/null
    fi
    [ $? -eq 0 ] || {
        echo "Error: Cannot connect to MySQL Server. Make sure username and password are set correctly in $0"
        exit 0
    }
}

### Make A Backup ###
backup_mysql() {
    if [ -d /etc/psa ]; then
        { local DBS="$(MYSQL_PWD=$(cat /etc/psa/.psa.shadow) $MYSQL -uadmin -Bse 'show databases')"; }
    else
        { local DBS="$($MYSQL -Bse 'show databases')"; }
    fi
    local db=""

    [ ! -d $MYSQLDUMPLOG ] && $MKDIR -p $MYSQLDUMPLOG
    [ ! -d $MYSQLDUMPPATH ] && $MKDIR -p $MYSQLDUMPPATH

    # find backup older than $DAYOLD and remove them
    $FIND $MYSQLDUMPPATH -type f -mtime +$DAYSOLD -exec $RM -f {} \; >>$MYSQLDUMPLOG/mysqldump.log 2>&1

    [ $LOGS -eq 1 ] && echo "" >>$MYSQLDUMPLOG/mysqldump.log 2>&1
    [ $LOGS -eq 1 ] && echo "*** Dumping MySQL Database At $(date) ***" >>$MYSQLDUMPLOG/mysqldump.log 2>&1
    [ $LOGS -eq 1 ] && echo "Database >> " >>$MYSQLDUMPLOG/mysqldump.log 2>&1

    for db in $DBS; do
        local TIME=$(date +"$TIME_FORMAT")
        local FILE="$MYSQLDUMPPATH/$db/$db.$TIME.gz"
        [ $LOGS -eq 1 ] && echo -e \\t "$db" >>$MYSQLDUMPLOG/mysqldump.log 2>&1

        if [ $db = "mysql" ] || [ $db = "performance_schema" ] || [ $db = "slow_query_log" ] || [ $db = "information_schema" ] || [ $db = "phpmyadmin" ]; then
            echo "mysql settings tables" >>$MYSQLDUMPLOG/mysqldump.log
        else
            [ ! -d $MYSQLDUMPPATH/$db ] && $MKDIR -p $MYSQLDUMPPATH/$db
            if [ -d /etc/psa ]; then
                MYSQL_PWD=$(cat /etc/psa/.psa.shadow) $MYSQLDUMP -uadmin --single-transaction $db $EXTRA_PARAMS | $COMPRESS $GZIP_ARG >$FILE || echo -e \\t \\t "MySQLDump Failed $db"
            else
                $MYSQLDUMP --single-transaction $db $EXTRA_PARAMS | $COMPRESS $GZIP_ARG >$FILE || echo -e \\t \\t "MySQLDump Failed $db"
            fi
        fi
    done

    [ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLDUMPPATH] ***" >>$MYSQLDUMPLOG/mysqldump.log 2>&1
}

## Backup all databases
backup_mysql_all_database() {

    [ $LOGS -eq 1 ] && echo "" >>$MYSQLDUMPLOG/mysqldump.log 2>&1
    [ $LOGS -eq 1 ] && echo "*** Dumping MySQL all-database At $(date) ***" >>$MYSQLDUMPLOG/mysqldump.log 2>&1

    local TIME=$(date +"$TIME_FORMAT")
    [ ! -d $MYSQLFULLDUMPPATH ] && $MKDIR -p $MYSQLFULLDUMPPATH
    local FILE="$MYSQLFULLDUMPPATH/all-database.$TIME.gz"
    if [ -d /etc/psa ]; then
        MYSQL_PWD=$(cat /etc/psa/.psa.shadow) $MYSQLDUMP -uadmin --all-databases --single-transaction --events | $COMPRESS $GZIP_ARG >$FILE || echo -e \\t \\t "MySQLDump Failed all-databases"
    else
        $MYSQLDUMP --all-databases --single-transaction --events | $COMPRESS $GZIP_ARG >$FILE || echo -e \\t \\t "MySQLDump Failed all-databases"
    fi
    [ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLFULLDUMPPATH] ***" >>$MYSQLDUMPLOG/mysqldumpl.log 2>&1
}

### Main ####
verify_bins
verify_mysql_connection
if [ "$SINGLE_DB" = "1" ]; then
    backup_mysql
fi
if [ "$ALLDB" = "1" ]; then
    backup_mysql_all_database
fi
