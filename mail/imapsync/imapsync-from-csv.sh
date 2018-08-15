#!/bin/bash

input="credentials.csv"
while IFS='|' read -r f1 f2 f3; do
    imapsync \
        --host1 "$1" \
        --user1 "$f1" \
        --ssl1 \
        --authmech1 LOGIN \
        --password1 "$f2" \
        --host2 "$2" \
        --ssl2 \
        --user2 "$f1" \
        --password2 "$f3" \
        --authmech2 LOGIN \
        --automap
done <"$input"
