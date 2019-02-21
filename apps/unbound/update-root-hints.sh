#!/bin/sh

# Source : https://www.shaftinc.fr/arretez-google-dns.html

TmpName=$(mktemp)
TmpDiff=$(mktemp)
TmpErr=$(mktemp)
REPORT_EMAIL="admin"
URL="https://www.internic.net/domain/named.cache"

wget -nv $URL -O $TmpName 2> $TmpErr

# On intercepte toute erreur
# et on stoppe le script dans ce cas
# On continue sinon

if [ "$?" -ne 0 ];then
	printf "\nScript was stopped at this point. A manual action may be required.\n" >> $TmpErr
	mail -s "[DNS - $(uname -n)] Root hints file download failed" $REPORT_EMAIL < $TmpErr
	rm $TmpErr
	rm $TmpDiff
	rm $TmpName
	exit 0
else
	rm $TmpErr
	shaTMP=$(sha512sum $TmpName | awk '{print $1}')
	shaHINTS=$(sha512sum /var/lib/unbound/root.hints | awk '{print $1}')

	if [ $shaTMP = $shaHINTS ]; then
	# Si le fichier récupéré est identique à celui
	# utilisé par Unbound, on fait... rien
		rm $TmpName
		exit 0
	else
		printf "A new root hints file was spotted on InterNIC server.\nFile downloaded and old root.hints file replaced.\nHere is the diff:\n\n" > $TmpDiff
		diff $TmpName /var/lib/unbound/root.hints >> $TmpDiff
		printf "\n\n" >> $TmpDiff
		mv -f $TmpName /var/lib/unbound/root.hints
		chown unbound: /var/lib/unbound/root.hints
		chmod 644 /var/lib/unbound/root.hints
		sleep 5
		service unbound restart
		printf "Unbound status is $(service unbound status | grep Active | awk '{print $2 " " $3}')\n" >> $TmpDiff
		mail -s "[DNS - $(uname -n)] Update in Root Hints" $REPORT_EMAIL < $TmpDiff
	rm $TmpDiff
	fi
fi
exit 0