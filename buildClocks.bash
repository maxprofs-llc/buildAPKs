#!/bin/env bash
# Copyright 2017-2019 (c) all rights reserved 
# by S D Rausty https://sdrausty.github.io
#####################################################################
set -Eeuo pipefail
shopt -s nullglob globstar

_SCLTRPERROR_() { # Run on script error.
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mbuildAPKs %s ERROR:  Signal %s received!\\e[0m\\n" "${0##*/}" "$RV"
	echo exit 201
	exit 201
}

_SCLTRPEXIT_() { # Run on exit.
	printf "\\e[?25h\\e[0m"
	set +Eeuo pipefail 
	exit
}

_SCLTRPSIGNAL_() { # Run on signal.
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mbuildAPKs %s WARNING:  Signal %s received!\\e[0m\\n" "${0##*/}" "$RV"
	echo exit 211
 	exit 211 
}

_SCLTRPQUIT_() { # Run on quit.
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mbuildAPKs %s WARNING:  Quit signal %s received!\\e[0m\\n" "${0##*/}" "$RV"
	echo exit 221
 	exit 221 
}

trap '_SCLTRPERROR_ $LINENO $BASH_COMMAND $?' ERR 
trap _SCLTRPEXIT_ EXIT
trap _SCLTRPSIGNAL_ HUP INT TERM 
trap _SCLTRPQUIT_ QUIT 

export DAY="$(date +%Y%m%d)"
export JID=Clocks
export NUM="$(date +%s)"
export RDR="$(cat $HOME/buildAPKs/var/conf/RDR)"   #  Set variable to contents of file.
export JDR="$RDR/sources/${JID,,}"
export SRDR="${RDR:33}" # search.string: string manipulation site:www.tldp.org
cd "$RDR"
(git pull && git submodule update --init ./scripts/shlibs) || (echo ; echo "Cannot update: continuing..." ; echo) # https://www.tecmint.com/chaining-operators-in-linux-with-practical-examples/
. "$RDR/scripts/shlibs/lock.bash"
if [[ ! -f "$RDR/sources/clocks/.git" ]] || [[ ! -f "$RDR/sources/livewallpapers/.git" ]] || [[ ! -f "$RDR/sources/widgets/.git" ]]
then
	echo
	echo "Updating buildAPKs; \`${0##*/}\` might want to load sources from submodule repositories into buildAPKs. This may take a little while to complete. Please be patient if this script wants to download source code from https://github.com"
	cd "$RDR"
	git submodule update --init --recursive ./sources/clocks
	git submodule update --init --recursive ./sources/livewallpapers
	git submodule update --init --recursive ./sources/widgets
else
	echo
	echo "To update module ~/buildAPKs/sources/clocks to the newest version remove the ~/buildAPKs/sources/clocks/.git file and run ${0##*/} again."
fi
find "$RDR/sources/clocks" -name AndroidManifest.xml \
	-execdir "$RDR/buildOne.bash" "$JID" {} \; \
	2>"$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/livewallpapers/android-clock-livewallpaper/"
../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/16-bit-clock/16-bit-clock/"
../../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/MonthCalendarWidget/choose-a/"
../../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/MonthCalendarWidget/romannurik/"
../../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/clockWidget/"
../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/decimal-clock-widget/decimal-clock-widget"
../../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
cd "$RDR/sources/widgets/unix-time-clock-widget/unix-time-clock"
../../../../buildOne.bash Clocks "$JID" 2> "$RDR/var/log/stnderr.${JID,,}.$NUM.log"
. "$RDR/scripts/shlibs/faa.bash" "$JID" "$JDR" ||:

#EOF
