#!/bin/bash
for i in $(seq 1 300); do 
	sed "${i}q;d" /NMT/finalTraining300/forge.test.or | /NMT/scripts/detokenizer | sed "s/\\\\n/\\n/g" 
	echo "----------"; 
	sed "${i}q;d" /NMT/finalTraining300/forge.test.sc | /NMT/scripts/detokenizer  | sed "s/\\\\n/\\n/g"
        echo "----------";
	sed "${i}q;d" output_test  | /NMT/scripts/detokenizer  | sed "s/\\\\n/\\n/g"
	echo "================================"; 
done
