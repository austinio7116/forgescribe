#!/bin/bash
setname=$1
wget -q -O /tmp/set.json "https://api.scryfall.com/sets/$setname?format=json"

sleep 0.1

count=`cat /tmp/set.json | jq .card_count`

echo "Found $count cards.."
echo -n "">/tmp/oracles.txt
for i in $(seq 1 $count);
do
	sleep 0.01
	wget -q -O /tmp/$i.json "https://api.scryfall.com/cards/$setname/$i?format=json"
	name=`cat /tmp/$i.json | jq .name | sed "s/\"//g"`
	echo $name
	cat /tmp/$i.json | jq .oracle_text | sed "s/\"//g" | sed "s/Oracle://g" | sed "s/${name}/CARDNAME/g" | sed "s///g" | sed "s/:/ COLON /g" | sed "s/|/ PIPE /g" | sed "s/\+/ PLUS /g" | sed "s/\-/ MINUS /g" | sed "s/\\$/ DOLLAR /g" | sed "s/{/ LCBRACE /g" | sed "s/}/ RCBRACE /g" | sed "s/</ LESSTHAN /g" | sed "s/>/ GREATERTHAN /g" | sed "s/\// SLASH /g" | sed "s/,/ COMMA /g" | sed "s/\./ POINT /g" | sed "s/\\\\n/ NEWLINE /g" | sed "s/^$/BLANK/g" | sed "s/(/ LBRACKET /g" | sed "s/)/ RBRACKET /g" | sed "s/'/ APOSTROPHE /g" | sed "s/—/ DASH /g"  | sed "s/&/ AMPERSAND /g" | sed "s/\"/ DOUBLEQUOTE /g" | sed "s/_/ UNDERSCORE /g" | sed "s/\// FORWARDSLASH /g" >>/tmp/oracles.txt
	cat /tmp/oracles.txt | wc -l
	if [[ `cat /tmp/oracles.txt | wc -l` -lt $i ]]; then
		echo "missing"
		echo "BLANK">>/tmp/oracles.txt
	fi
done

#tail -n +2 /tmp/oracles.txt > /tmp/temp.txt
#mv /tmp/temp.txt /tmp/oracles.txt


echo "Transcribing cards..."

currentdir=`pwd`

cd /NMT/
python -m nmt.nmt --out_dir=nmt_model_412_4 --src=or --tgt=sc --inference_input_file=/tmp/oracles.txt --inference_output_file=/tmp/oracles.out --vocab_prefix=./nmt/testdata/forge.vocab
cd $currentdir

echo "Writing Card scripts..."

for i in $(seq 1 $count);
do
	reprint=`cat /tmp/$i.json | jq .reprint | sed "s/\"//g"`
	if [[ $reprint == "true" ]]; then
		continue
	fi
	name=`cat /tmp/$i.json | jq .name | sed "s/\"//g"`
	echo $name
	filename=`echo $name | sed "s/,//g" | sed "s/ /_/g" | sed "s/'//g" | tr '[:upper:]' '[:lower:]' | sed "s/-/_/g" | sed "s/_\/\/_.*//g"`.txt
	echo "Name:${name}">$filename
	manacost=`cat /tmp/$i.json | jq .mana_cost | sed "s/[\"]//g" | sed "s/}{/ /g" | sed "s/[{}]//g"`
	echo "ManaCost:${manacost}">>$filename
	types=`cat /tmp/$i.json | jq .type_line | sed "s/\"//g" | sed "s/ —//g"`
	echo "Types:${types}">>$filename
	if [ `echo "$types" | grep Creature | wc -l` -gt 0 ]; then 
		power=`cat /tmp/$i.json | jq .power | sed "s/\"//g"`
		toughness=`cat /tmp/$i.json | jq .toughness | sed "s/\"//g"`
		echo "PT:$power/$toughness">>$filename
	fi
	if [ `echo "$types" | grep Planeswalker | wc -l` -gt 0 ]; then 
		loyalty=`cat /tmp/$i.json | jq .loyalty | sed "s/\"//g"`
		echo "Loyalty:$loyalty">>$filename
	fi
	script=`cat /tmp/oracles.out | sed "${i}q;d" | sed "s/ *SLASH */\//g" | sed "s/ *COLON */:/g" | sed "s/ *DOLLAR */$ /g" | sed "s/PIPE/|/g" | sed "s/ POINT */\./g" | sed "s/ COMMA /,/g" | sed "s/ LCBRACE /{/g" | sed "s/ RCBRACE */}/g" | sed "s/ *PLUS */+/g" | sed "s/ LESSTHAN /</g" | sed "s/ GREATERTHAN/>/g" | sed "s/ APOSTROPHE /'/g" | sed "s/ LBRACKET /(/g"  | sed "s/ RBRACKET /)/g" | sed "s/ APOSTROPHE /'/g" | sed "s/ DASH /-/g" | sed "s/ AMPERSAND /&/g"  | sed "s/ DOUBLEQUOTE /\"/g" | sed "s/ UNDERSCORE /_/g" | sed "s/ FORWARDSLASH /\//g" | sed "s/BLANK//g"| sed "s/ *NEWLINE */\\n/g" | sed "s/ *MINUS */-/g" | sed -r "s/([^ ])(\+[0-9]+\/\+[0-9]+)/\1 \2/g"`
	if [ `echo "$types" | grep Sorcery | wc -l` -gt 0 ] || [ `echo "$types" | grep Instant | wc -l` -gt 0 ] || [ `echo "$types" | grep Enchantment | wc -l` -gt 0 ]; then
		script=`echo $script | sed "s/| Cost$ 4 R R |/| Cost$ $manacost |/g"`
	fi
	echo $script | sed "s///g" >> $filename
	oracle=`cat /tmp/$i.json | jq .oracle_text | sed "s/\"//g"`
	echo "Oracle:${oracle}" >> $filename
done


