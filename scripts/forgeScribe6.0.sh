#!/bin/bash
stringin=`cat <&0`
model=nmt_model_335_war_out
#model=nmt_model_cpu_gnmt/best_bleu
head -31 /NMT/presparktraining/forge.test.or > /tmp/tokenedoracle
echo $stringin | /NMT/scripts/tokenizer >> /tmp/tokenedoracle
currentdir=`pwd`
cd /NMT/
python -m nmt.nmt --ckpt=${model}/best_bleu/translate.ckpt-34000 --out_dir=${model} --src=or --tgt=sc --inference_input_file=/tmp/tokenedoracle --inference_output_file=/tmp/tokenedscript --vocab_prefix=./${model}/forge.vocab > /dev/null 2>&1
#python -m nmt.nmt --out_dir=./nmt_model_gnmt/best_bleu/ --src=or --tgt=sc --tgt_max_len=512 --num_units=512 --hparams_path=/NMT/nmt/standard_hparams/forge.json --inference_input_file=/tmp/tokenedoracle --inference_output_file=/tmp/tokenedscript --vocab_prefix=./nmt_model_gnmt/forge.vocab > /dev/null 2>&1
cd $currentdir
tail -1 /tmp/tokenedscript | /NMT/scripts/detokenizer
