#!/bin/bash

TS_CURRENT="$(date +%s)"
LOGDIR="../logs/$(TZ=GMT date -Iseconds -d@"$TS_CURRENT")"

mkdir "$LOGDIR"

bash -x ./make.sh "$TS_CURRENT" "$LOGDIR" > "$LOGDIR/make.sh.txt" 2>&1

#clean up logs if nothing has changed
if [ "$?" == "4" ]; then
	rm -r "$LOGDIR"
fi
