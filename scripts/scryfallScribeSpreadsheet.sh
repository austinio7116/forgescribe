#!/bin/bash

echo -n "">/tmp/oracles.txt
IFS=$'\n'       # make newlines the only separator
for line in $(cat $1)    
do
	
	name=`echo $line | cut -d "|" -f 1`
	shortname=`echo "$name" | sed -r "s/([A-Za-z]+),.*/\1/g"`
	#echo $name
	filename=`echo $name | sed "s/,//g" | sed "s/ /_/g" | sed "s/'//g" | tr '[:upper:]' '[:lower:]' | sed "s/-/_/g" | sed "s/_\/\/_.*//g"`.txt
	if [ -f $filename ]; then
		continue
	fi
        echo "Name:${name}">$filename
        manacost=`echo $line | cut -d "|" -f 5 | sed 's/./& /g'`
        echo "ManaCost:${manacost}">>$filename
        types=`echo $line | cut -d "|" -f 4`
        echo "Types:${types}">>$filename
        if [ `echo "$types" | grep Creature | wc -l` -gt 0 ]; then
                power=`echo $line | cut -d "|" -f 2`
                toughness=`echo $line | cut -d "|" -f 3`
                echo "PT:$power/$toughness">>$filename
        fi
        if [ `echo "$types" | grep Planeswalker | wc -l` -gt 0 ]; then
                loyalty=`cat /tmp/$i.json | jq .loyalty | sed "s/\"//g"`
                echo "Loyalty:$loyalty">>$filename
        fi
	if [ `echo "$types" | grep Enchantment | wc -l` -gt 0 ]; then
		echo $line | cut -d "|" -f 7 | sed "s/Spacemarines/Goblins/g" | sed "s/Eldar/Elves/g" | sed "s/\\\"/\"/g" | sed "s/$name/CARDNAME/g" | sed "s/$shortname/CARDNAME/g" | sed -r "s/\\\\n([{+0])/\n\1/g" | sed "s/—/-/g" | sed -r "s/\\\\n([-−�]+)/\n-/g" | sed "s/\\\\n/\n/g" > /tmp/oracles.txt # | sed "s/\\\\n/\n/g" > /tmp/oracles.txt #| sed "s/NEWLINE/\n/g" > /tmp/oracles.txt
	else
		echo $line | cut -d "|" -f 7 | sed "s/Spacemarines/Goblins/g" | sed "s/Eldar/Elves/g" | sed "s/\\\"/\"/g" | sed "s/$name/CARDNAME/g" | sed "s/$shortname/CARDNAME/g" | sed -r "s/\\\\n([{+0])/\n\1/g" | sed "s/—/-/g" | sed -r "s/\\\\n([-−�]+)/\n-/g" | sed "s/\\\\n/\n/g" > /tmp/oracles.txt # | sed "s/\\\\n/\n/g" > /tmp/oracles.txt   #| sed "s/NEWLINE/\n/g" > /tmp/oracles.txt
	fi
        #cat /tmp/oracles.txt
        if [[ `tail -1 /tmp/oracles.txt` != "null" ]]; then
		lines=`cat /tmp/oracles.txt | wc -l`
		updateCost="true"
		for j in `seq 1 $lines`; do
			sed "${j}q;d" /tmp/oracles.txt | /NMT/scripts/forgeScribe7.0.sh > /tmp/script.out
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
        		cat /tmp/script.out | sed "s/Goblins/Spacemarines/g" | sed "s/Elves/Eldar/g" | sed "s/Goblin/Spacemarine/g" | sed "s/Elf/Eldar/g" | grep ":" >> $filename
		done
		oracle=`echo $line | cut -d "|" -f 7 | sed "s/\\\\\\\\\"/\"/g"`
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

