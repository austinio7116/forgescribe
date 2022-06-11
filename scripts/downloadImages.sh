#!/bin/bash

IFS=$'\n'       # make newlines the only separator
for line in $(cat $1)    
do
	
	name=`echo $line | cut -d "|" -f 1`
	url=`echo $line | cut -d "|" -f 8`
	wget $url -q -O "${name}.png"
done

