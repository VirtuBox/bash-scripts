# MySQLDump Backup Script

Modified First By: Mitesh Shah  
Then Modified By : VirtuBox  
Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>  
This script is licensed under GNU GPL version 2.0 or above  
This script is part of nixCraft shell script collection (NSSC)  
Visit http://bash.cyberciti.biz/ for more information.  


## Download the script

```bash
wget https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/backup/mysqldump/mysqldump.sh -O mysqldump.sh
chmod +x mysqldump.sh
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
