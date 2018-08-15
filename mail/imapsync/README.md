# Script to migrate emails between two servers using imapsync - user credentials read from csv

## Download the script and csv example

```bash
wget https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/mail/imapsync/imapsync-from-csv.sh -O imapsync-from-csv.sh
wget https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/mail/imapsync/credentials.csv -O credentials.csv
chmod +x imapsync-from-csv.sh
```

## Run the script

Put your users crendentials in the csv file, and run imapsync-from-csv.sh this way :

```bash
./imapsync-from-csv.sh imap-server-1.tld imap-server-2.tld
```
