#!/bin/bash
echo "">forge.raw.sc
echo "">forge.raw.or
for file in */*.txt; do
	name=`cat $file | grep "Name:" | head -1 | sed "s/Name://g" | tr '\n' ' ' | tr '\r' ' ' | sed "s/'/£/g" | xargs | sed "s/£/'/g"`
	echo "$name"
	text=`cat $file | grep -E -v "^#|SVar:DeckHints|SVar:DeckNeeds|SVar:AIHints|SVar:RemAIDeck|Name:|ManaCost:|Types:|Oracle:|PT:|Loyalty:|SVar:Picture:" | sed -E ':a;N;$!ba;s/\r{0,1}\n/ NEWLINE /g' | sed "s/${name}/CARDNAME/g"`
	echo $text>>forge.raw.sc
	oracle=`cat $file | grep "Oracle:" | sed "s/Oracle://g" | sed "s/${name}/CARDNAME/g"`
	echo $oracle>>forge.raw.or
done

#cleanup

cat forge.raw.sc | sed "s///g" | sed "s/:/ COLON /g" | sed "s/|/ PIPE /g" | sed "s/\+/ PLUS /g" | sed "s/\-/ MINUS /g" | sed "s/\\$/ DOLLAR /g" | sed "s/{/ LCBRACE /g" | sed "s/}/ RCBRACE /g" | sed "s/</ LESSTHAN /g" | sed "s/>/ GREATERTHAN /g" | sed "s/\// SLASH /g" | sed "s/,/ COMMA /g" | sed "s/\./ POINT /g" | sed "s/^$/BLANK/g" | sed "s/(/ LCBRACKET /g" | sed "s/)/ RBRACKET /g" | sed "s/'/ APOSTROPHE /g" | sed "s/—/ DASH /g" > forge.all.sc

cat forge.raw.or | sed "s///g" | sed "s/:/ COLON /g" | sed "s/|/ PIPE /g" | sed "s/\+/ PLUS /g" | sed "s/\-/ MINUS /g" | sed "s/\\$/ DOLLAR /g" | sed "s/{/ LCBRACE /g" | sed "s/}/ RCBRACE /g" | sed "s/</ LESSTHAN /g" | sed "s/>/ GREATERTHAN /g" | sed "s/\// SLASH /g" | sed "s/,/ COMMA /g" | sed "s/\./ POINT /g" | sed "s/\\\\n/ NEWLINE /g" | sed "s/^$/BLANK/g" | sed "s/(/ LCBRACKET /g" | sed "s/)/ RBRACKET /g" | sed "s/'/ APOSTROPHE /g" | sed "s/—/ DASH /g" > forge.all.or

#generate vocab
for word in `cat forge.all.or | sed "s/\\\\\\\\n/ NEWLINE /g" | tr '\n' ' ' | tr '\r' ' '`; do echo $word;done > forge.vocab.or
cat forge.vocab.or | sed "s/[^A-Za-z0-9\|]//g" | sort | uniq > forge.vocabfinal.or
mv forge.vocabfinal.or forge.vocab.or

for word in `cat forge.all.sc | sed "s/\\\\\\\\n/ NEWLINE /g" | tr '\n' ' ' | tr '\r' ' '`; do echo $word;done > forge.vocab.sc
cat forge.vocab.sc | sed "s/[^A-Za-z0-9\|]//g" | sort | uniq > forge.vocabfinal.sc
mv forge.vocabfinal.sc forge.vocab.sc

#conver to ascii

for file in forge.*; do iconv -f UTF8 -t ASCII -c $file > ${file}.clean; done

for file in forge.*.clean; do mv $file ${file%.*}; done

#split test train
head -100 forge.all.or | sed "s///g" > forge.100.or
head -100 forge.all.sc | sed "s///g" > forge.100.sc
tail -n +100 forge.all.or | sed "s///g" > forge.train.or
tail -n +100 forge.all.sc | sed "s///g" > forge.train.sc

