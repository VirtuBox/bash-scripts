#!/usr/bin/env bash
# -------------------------------------------------------------------------
# Modified First By: Mitesh Shah
# Then Modified By : VirtuBox
# Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------

### Enable Log = 1 ###
LOGS=1

### Default Time Format ###
TIME_FORMAT='%d-%b-%Y-%H%M%S'

### Setup Dump And Log Directory ###
MYSQLDUMPPATH=/var/www/mysqldump
MYSQLFULLDUMPPATH="$MYSQLDUMPPATH/full"
MYSQLDUMPLOG=/var/log/mysqldump.log
EXTRA_PARAMS=""

### Remove Backup older than X days ###
DAYSOLD=3

### Backup all-databases in a single file ###
ALLDB=0
SINGLE_DB=1

if [ -d /etc/psa ]; then
    readonly MYSQL_PWD=$(cat /etc/psa/.psa.shadow)
    MYSQL_USER="-uadmin"
else
    MYSQL_USER=""
fi

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

# check if a command exist
command_exists() {
    command -v "$@" >/dev/null 2>&1
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

### Make Sure Bins Exists ###
verify_bins() {

    if command_exists zstd; then
        COMPRESS=$(command -v zstd)
        GZIP_ARG="-T0"
    else
        if command_exists pigz; then

            COMPRESS=$(command -v pigz)
            NCPU=$(nproc)
            GZIP_ARG="-9 -p$NCPU"
        else
            COMPRESS=$(command -v gzip)
            GZIP_ARG="-1"
        fi
    fi

    if ! command_exists mysql; then
        echo "mysql isn't available."
        exit 0
    else
        MYSQL=$(command -v mysql)
    fi
    if ! command_exists mysqldump; then
        echo "mysqldump isn't available"
        exit 0
    else
        MYSQLDUMP=$(command -v mysqldump)
    fi
    if ! command_exists mysqladmin; then
        echo "mysqladmin isn't available"
        exit 0
    else
        MYSQLADMIN=$(command -v mysqladmin)
    fi
}

### Check if .my.cnf exit or if Plesk is installed
if [ ! -f ~/.my.cnf ] && [ ! -f /etc/mysql/conf.d/my.cnf ] && [ ! -d /etc/psa ]; then
    echo "Error: ~/.my.cnf not found"
    exit 0
fi

### Make Sure We Can Connect To The Server ###
verify_mysql_connection() {
    if ! {
        $MYSQLADMIN "$MYSQL_USER" ping | grep -q 'alive' >/dev/null
    }; then
        echo "Error: Cannot connect to MySQL Server. Make sure username and password are set correctly in $0"
        exit 0
    fi
}

### Make A Backup ###
backup_mysql() {
    local DBS
    DBS=$($MYSQL "$MYSQL_USER" -Bse 'show databases')
    local db=""

    [ ! -d "$MYSQLDUMPLOG" ] && mkdir -p "$MYSQLDUMPLOG"
    [ ! -d "$MYSQLDUMPPATH" ] && mkdir -p "$MYSQLDUMPPATH"

    # find backup older than $DAYOLD and remove them
    find "$MYSQLDUMPPATH" -type f -mtime +$DAYSOLD -exec rm -f {} \; >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1 &

    [ $LOGS -eq 1 ] && echo "" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1
    [ $LOGS -eq 1 ] && echo "*** Dumping MySQL Database At $(date) ***" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1
    [ $LOGS -eq 1 ] && echo "Database >> " >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1

    for db in $DBS; do
        local TIME
        TIME=$(date +"$TIME_FORMAT")
        local FILE
        FILE="$MYSQLDUMPPATH/$db/$db.$TIME.gz"
        [ $LOGS -eq 1 ] && echo -e \\t "$db" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1

        if [ "$db" = "mysql" ] || [ "$db" = "performance_schema" ] || [ "$db" = "slow_query_log" ] || [ "$db" = "information_schema" ] || [ "$db" = "phpmyadmin" ]; then
            echo "mysql settings tables" >>"$MYSQLDUMPLOG/mysqldump.log"
        else
            [ ! -d "$MYSQLDUMPPATH/$db" ] && mkdir -p "$MYSQLDUMPPATH/$db"
            $MYSQLDUMP "$MYSQL_USER" --single-transaction --max_allowed_packet=1024M --hex-blob "$db" "$EXTRA_PARAMS" | $COMPRESS $GZIP_ARG >"$FILE" || echo -e \\t \\t "MySQLDump Failed $db"
        fi
    done
    wait
    [ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLDUMPPATH] ***" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1
}

## Backup all databases
backup_mysql_all_database() {

    [ $LOGS -eq 1 ] && echo "" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1
    [ $LOGS -eq 1 ] && echo "*** Dumping MySQL all-database At $(date) ***" >>"$MYSQLDUMPLOG/mysqldump.log" 2>&1

    local TIME
    TIME=$(date +"$TIME_FORMAT")
    [ ! -d $MYSQLFULLDUMPPATH ] && mkdir -p $MYSQLFULLDUMPPATH
    local FILE="$MYSQLFULLDUMPPATH/all-database.$TIME.gz"
    $MYSQLDUMP "$MYSQL_USER" --all-databases --hex-blob --max_allowed_packet=1024M --single-transaction --events | $COMPRESS $GZIP_ARG >"$FILE" || echo -e \\t \\t "MySQLDump Failed all-databases" &
    [ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLFULLDUMPPATH] ***" >>"$MYSQLDUMPLOG/mysqldumpl.log" 2>&1
    wait
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
