#!/bin/bash

set -o nounset
set -o errexit

TS_CURRENT="$1"
LOGDIR="$2"

TODAY=$(date -I)
TS_BEFORE="$(stat --printf %Y archzfs.db || true)"
wget -N http://archzfs.com/archzfs/x86_64/archzfs.db
TS_AFTER="$(stat --printf %Y archzfs.db)"

LAST_MOD=$(TZ=GMT date "+%a, %d %b %Y %T %Z" -d@"$TS_AFTER")
LAST_RUN=$(TZ=GMT date "+%a, %d %b %Y %T %Z" -d@"$TS_CURRENT")

if [ "${TS_BEFORE}" != "${TS_AFTER}" ]; then
	cat > ../last-run.txt <<_
Last-Modified: $LAST_MOD
$(TZ=GMT date "+Last-Processed: %a, %d %b %Y %T %Z")
Last-Checked: $LAST_RUN
_

#	rm -f *.xz *.sig *.db *.log *.lck *.files || true

	xzcat archzfs.db | perl makedb.pl > "$LOGDIR/parse-archzfs.db.txt"

	wget -c -i urls --progress=dot:mega -o "$LOGDIR/wget.txt" || true

	rm -r zfs-*/ || true

	bash repo-add.sh > $LOGDIR/repo-add.sh.txt 2>&1 || true
else
	sed -re "s/^(Last-Checked: ).*/\1${LAST_RUN}/" -i ../last-run.txt
	exit 4
fi
