#!/bin/bash

set -o nounset
set -o errexit

TODAY=$(date -I)
LAST_MOD=$(curl -sI http://archzfs.com/archzfs/x86_64/archzfs.db | grep -- '^Last-Modified')
LAST_JOB=$(head -1 last-run.txt || true)
LAST_RUN=$(TZ=GMT date "+%a, %d %b %Y %T %Z")

if [ "${LAST_MOD}" != "${LAST_JOB}" ]; then
	cat > last-run.txt <<_
$LAST_MOD
$(TZ=GMT date "+Last-Processed: %a, %d %b %Y %T %Z")
Last-Checked: $LAST_RUN
_

#	rm -f *.xz *.sig *.db *.log *.lck *.files || true

	curl -s http://archzfs.com/archzfs/x86_64/archzfs.db | xzcat | perl makedb.pl

	wget -i urls -nc -o "download-${TODAY}.log" || true

	rm -r zfs-*/ || true

	. repo-add.sh

#    rm *.pkg.tar.*

	#echo -- "${LAST_MOD}" >> last-run.txt
else
	sed -re "s/^(Last-Checked: ).*/\1${LAST_RUN}/" -i last-run.txt
fi
