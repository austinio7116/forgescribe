#!/bin/bash
setname=$1
wget -q -O /tmp/setinfo.json "https://api.scryfall.com/sets/$setname?format=json"
wget "https://api.scryfall.com/cards/search?order=set&unique=art&q=set%3D$setname" -q -O /tmp/set.json

cat /tmp/set.json | jq ".data | .[].collector_number" | sed "s/\"//g" > /tmp/cardidlist

hasmore=`cat /tmp/set.json | jq ".has_more" | sed "s/\"//g"`
nextpage=`cat /tmp/set.json | jq ".next_page" | sed "s/\"//g"`
while [ $hasmore ] ; do
	sleep 0.01
	wget "$nextpage" -q -O /tmp/next.json
	cat /tmp/next.json | jq ".data | .[].collector_number" | sed "s/\"//g" >> /tmp/cardidlist
	hasmore=`cat /tmp/next.json | jq ".has_more" | sed "s/\"//g"`
	nextpage=`cat /tmp/next.json | jq ".next_page" | sed "s/\"//g"`
done


cardIDs=($(cat /tmp/cardidlist | sort))

sleep 0.1

echo "Found ${#cardIDs[@]} cards.."
echo -n "">/tmp/oracles.txt
for i in "${cardIDs[@]}"
do
	sleep 0.01
	wget -q -O /tmp/$i.json "https://api.scryfall.com/cards/$setname/$i?format=json"
	reprint=`cat /tmp/$i.json | jq .reprint | sed "s/\"//g"`
        if [[ $reprint == "true" ]]; then
                continue
        fi
	name=`cat /tmp/$i.json | jq .name | sed "s/\"//g"`
	shortname=`echo "$name" | sed -r "s/([A-Za-z]+),.*/\1/g"`
	#echo $name
	filename=`echo $name | sed "s/,//g" | sed "s/ /_/g" | sed "s/'//g" | tr '[:upper:]' '[:lower:]' | sed "s/-/_/g" | sed "s/_\/\/_.*//g"`.txt
	if [ -f $filename ]; then
		continue
	fi
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
	if [ `echo "$types" | grep Enchantment | wc -l` -gt 0 ]; then
		cat /tmp/$i.json | jq .oracle_text | sed "s/^\"//g" | sed "s/\"$//g" | sed "s/\\\"/\"/g" | sed "s/$name/CARDNAME/g" | sed "s/$shortname/CARDNAME/g" | sed -r "s/\\\\n([{+0])/\n\1/g" | sed "s/—/-/g" | sed -r "s/\\\\n([-−�]+)/\n-/g" > /tmp/oracles.txt # | sed "s/\\\\n/\n/g" > /tmp/oracles.txt #| sed "s/NEWLINE/\n/g" > /tmp/oracles.txt
	else
		cat /tmp/$i.json | jq .oracle_text | sed "s/^\"//g" | sed "s/\"$//g" | sed "s/\\\"/\"/g" | sed "s/$name/CARDNAME/g" | sed "s/$shortname/CARDNAME/g" | sed -r "s/\\\\n([{+0])/\n\1/g" | sed "s/—/-/g" | sed -r "s/\\\\n([-−�]+)/\n-/g" | sed "s/\\\\n/\n/g" > /tmp/oracles.txt   #| sed "s/NEWLINE/\n/g" > /tmp/oracles.txt
	fi
	if [[ `cat /tmp/$i.json | jq .card_faces` != "null" ]]; then
		cat /tmp/$i.json | jq .card_faces[].oracle_text | sed "s/^\"//g" | sed "s/\"$//g" | sed "s/\\\"/\"/g" | sed "s/$name/CARDNAME/g" | sed "s/$shortname/CARDNAME/g" | sed -r "s/\\\\n([{+0])/\n\1/g" | sed "s/—/-/g" | sed -r "s/\\\\n([-−�]+)/\n-/g" | sed "s/\\\\n/\n/g" > /tmp/oracles.txt   #| sed "s/NEWLINE/\n/g" > /tmp/oracles.txt
	fi
        #cat /tmp/oracles.txt
        if [[ `tail -1 /tmp/oracles.txt` != "null" ]]; then
		lines=`cat /tmp/oracles.txt | wc -l`
		updateCost="true"
		for j in `seq 1 $lines`; do
			sed "${j}q;d" /tmp/oracles.txt | /NMT/scripts/forgeScribe6.0.sh > /tmp/script.out
			#cat /tmp/oracles.out
			if [ $updateCost ]; then
	        		if [ `echo "$types" | grep Sorcery | wc -l` -gt 0 ] || [ `echo "$types" | grep Instant | wc -l` -gt 0 ] || [ `echo "$types" | grep Enchantment | wc -l` -gt 0 ]; then
        			        cat /tmp/script.out | sed "s/Cost$ [0-9WUBGRX ]* /Cost$ $manacost /g" > /tmp/tempscript.out
                			mv /tmp/tempscript.out /tmp/script.out
					updateCost="false"
        			fi
			fi
			if [ `echo "$types" | grep Planeswalker | wc -l` -gt 0 ]; then
				firstchar=`sed "${j}q;d" /tmp/oracles.txt| cut -c 1`
				counters=` sed "${j}q;d" /tmp/oracles.txt | sed -r "s/[{+-]([0-9]+).*/\1/g"`
				if [ $firstchar == "+" ]; then
					cat /tmp/script.out | sed "s/Cost$ [0-9]* /Cost$ AddCounter<${counters}\/LOYALTY> | Planeswalker$ True /g" > /tmp/tempscript.out
                                	mv /tmp/tempscript.out /tmp/script.out
				fi
				if [ $firstchar == "-" ]; then
                                        cat /tmp/script.out | sed "s/Cost$ [0-9]* /Cost$ SubCounter<${counters}\/LOYALTY> | Planeswalker$ True /g" > /tmp/tempscript.out
                                        mv /tmp/tempscript.out /tmp/script.out
                                fi
			fi
        		cat /tmp/script.out | grep ":" >> $filename
		done
		oracle=`cat /tmp/$i.json | jq .oracle_text | sed "s/^\"//g" | sed "s/\"$//g"  | sed -r "s/([-+][0-9]+):/\[\1\]:/g" | sed "s/\\\\\\\\\"/\"/g"`
	        echo "Oracle:${oracle}" >> $filename
	else
		echo "Oracle:" >> $filename	
	fi
	if [ `echo "$types" | grep Creature | wc -l` -gt 0 ]; then
		sed -i "/SVar:NonStackingEffect:True/ d" $filename
	fi
	cat $filename
	echo ""; echo "============================="; echo "";
done

