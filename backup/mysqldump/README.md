# MySQLDump Backup Script

## Download the script

```bash
wget https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/backup/mysqldump/mysqldump.sh -O mysqldump.sh
chmod +x mysqldump.sh
```

## Optional

Install pigz for multithreaded compression

```bash
sudo apt update && apt install pigz -y
```

## Add cronjob

```bash
crontab -e

# every 6 hours
0 */6 * * * /root/mysqldump.sh > /dev/null 2>&1

# every 12 hours
0 */12 * * * /root/mysqldump.sh > /dev/null 2>&1

# every 24 hours
@daily /root/mysqldump.sh > /dev/null 2>&1

```
