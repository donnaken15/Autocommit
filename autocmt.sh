#!/bin/bash

if [ $# == 0 ]; then
	echo "No arguments specified"
	echo ""
	# ^ how to line break
	echo "Usage:"
	echo "autocmt ~/Documents/myrepo"
	exit
fi

if [ -d $1 ]; then
	cd $1
	if [ ! -d .git ]; then
		echo "This is not a repository"
		exit
	fi
else
	echo "Invalid directory"
	exit
fi

declare -i a

#git restore --staged .
git reset HEAD .
git status --porcelain | grep -E '[AM]?[^\?]\s+.*' | cut -c4- > /tmp/autocmt.lst
echo -n "autocmt: " > /tmp/autocmt.msg
for MODFILES in $(</tmp/autocmt.lst)
do
	echo -n "$MODFILES: ..." >> /tmp/autocmt.msg
	a=$RANDOM/4000+1
	echo -n $((git diff --word-diff -U0 $MODFILES 2>&1 | grep -E "{\+.+\+}" | sed -E 's/\s?(\[-.*-\])?\{\+//' | sed -E 's/\+\}//') | cut -c$a-$(echo "$a+16" | bc)) >> /tmp/autocmt.msg
	# stupid thing --> | awk -F: '{ printf $1}' |
	echo -n "... " >> /tmp/autocmt.msg
done
git status --porcelain | grep -E '\?\?\s+.*' | cut -c4- > /tmp/autocmt.lst
for NEWFILES in $(</tmp/autocmt.lst)
do
	echo -n "$NEWFILES: ..." >> /tmp/autocmt.msg
	a=$RANDOM/4000+1
	echo -n $(awk -F: '{ printf $1 }' $NEWFILES | cut -c$a-$(echo "$a+16" | bc)) >> /tmp/autocmt.msg
	echo -n "... " >> /tmp/autocmt.msg
done
git add .
git commit -m "$(</tmp/autocmt.msg)"

if [ "$2" == "-p" ]; then
	git push
fi
