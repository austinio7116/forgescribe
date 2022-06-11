#!/bin/bash
setname=$1
wget -q -O /tmp/set.json "https://api.scryfall.com/sets/$setname?format=json"

sleep 0.1

count=`cat /tmp/set.json | jq .card_count`

echo "Found $count cards.."
echo "">oracles.txt
for i in $(seq 1 $count);
do
	sleep 0.1
	wget -q -O /tmp/$i.json "https://api.scryfall.com/cards/$setname/$i?format=json"
	name=`cat /tmp/$i.json | jq .name | sed "s/\"//g"`
	echo $name
	cat /tmp/$i.json | jq .oracle_text | sed "s/\"//g" | sed "s/Oracle://g" | sed "s/${name}/CARDNAME/g" | sed "s///g" | sed "s/:/ COLON /g" | sed "s/|/ PIPE /g" | sed "s/\+/ PLUS /g" | sed "s/\-/ MINUS /g" | sed "s/\\$/ DOLLAR /g" | sed "s/{/ LCBRACE /g" | sed "s/}/ RCBRACE /g" | sed "s/</ LESSTHAN /g" | sed "s/>/ GREATERTHAN /g" | sed "s/\// SLASH /g" | sed "s/,/ COMMA /g" | sed "s/\./ POINT /g" | sed "s/\\\\n/ NEWLINE /g" | sed "s/^$/BLANK/g" | sed "s/(/ LBRACKET /g" | sed "s/)/ RBRACKET /g" | sed "s/'/ APOSTROPHE /g" | sed "s/—/ DASH /g"  | sed "s/&/ AMPERSAND /g" | sed "s/\"/ DOUBLEQUOTE /g" | sed "s/_/ UNDERSCORE /g" | sed "s/\// FORWARDSLASH /g" >>oracles.txt
done


