nohup python -m nmt.nmt  --src=or --tgt=sc --vocab_prefix=./nmt/testdata/forge.vocab  --train_prefix=./nmt/testdata/forge.train --dev_prefix=./nmt/testdata/forge.100  --test_prefix=./nmt/testdata/forge.100 --out_dir=nmt_model_gru --num_train_steps=24000 --steps_per_stats=100 --num_layers=2 --num_units=384 --dropout=0.2 --metrics=bleu --src_max_len=384 --tgt_max_len=384 --attention scaled_luong --num_gpus=2 --encoder_type=bi --unit_type=gru &


nohup python -m nmt.nmt  --src=or --tgt=sc --vocab_prefix=./nmt/testdata/forge.vocab  --train_prefix=./nmt/testdata/forge.train --dev_prefix=./nmt/testdata/forge.100  --test_prefix=./nmt/testdata/forge.100 --out_dir=nmt_model_384_5 --num_train_steps=24000 --steps_per_stats=100 --num_layers=4 --num_units=384 --dropout=0.2 --metrics=bleu --src_max_len=384 --tgt_max_len=384 --attention scaled_luong --num_gpus=2 --encoder_type=bi --subword_option=bpe &


nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./randtestdata/forge.vocab --train_prefix=./randtestdata/forge.train --dev_prefix=./randtestdata/forge.100 --test_prefix=./randtestdata/forge.100 --out_dir=nmt_model_192_8 --num_train_steps=24000 --steps_per_stats=100 --num_layers=2 --num_units=192 --dropout=0.2 --metrics=bleu --src_max_len=128 --tgt_max_len=256 --attention scaled_luong --num_gpus=2 &

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./randtestdata/forge.vocab --train_prefix=./randtestdata/forge.train --dev_prefix=./randtestdata/forge.100 --test_prefix=./randtestdata/forge.100 --out_dir=nmt_model_192_9 --num_train_steps=24000 --steps_per_stats=100 --num_layers=2 --num_units=192 --dropout=0.2 --metrics=bleu --src_max_len=128 --tgt_max_len=256 --attention scaled_luong --num_gpus=2  --encoder_type=bi --subword_option=bpe --beam-width=3 &




nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining3600/forge.vocab --train_prefix=./finalTraining3600/forge.train --dev_prefix=./finalTraining3600/forge.dev --test_prefix=./finalTraining3600/forge.test --out_dir=nmt_model_gnmt --hparams_path=/NMT/nmt/standard_hparams/forge.json --num_gpus=2 &
nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining3600/forge.vocab --train_prefix=./finalTraining3600/forge.train --dev_prefix=./finalTraining3600/forge.dev --test_prefix=./finalTraining3600/forge.test --out_dir=nmt_model_gnmt --hparams_path=/NMT/nmt/standard_hparams/cpu.json &

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining900/forge.vocab --train_prefix=./finalTraining900/forge.train --dev_prefix=./finalTraining900/forge.dev --test_prefix=./finalTraining900/forge.test --out_dir=nmt_model_bi_335_2 --hparams_path=/NMT/nmt/standard_hparams/forge.json --num_gpus=2 &


best bleu 70+ 356_13  num_layers 4 tgt_max_len 365 attention_architecture standard  attention scaled_luong src_max_len: 150 encoder_type bi subword_option NONE
 was during the SCP additions when the start and end punctuation was still present


 nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining300/forge.vocab --train_prefix=./finalTraining300/forge.train --dev_prefix=./finalTraining300/forge.dev --test_prefix=./finalTraining300/forge.test --out_dir=nmt_model_bi_335_2 --hparams_path=/NMT/nmt/standard_hparams/forge.json --num_gpus=2 &


maybe try increasing regularization with dropout of 0.5?

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining300/forge.vocab --train_prefix=./finalTraining300/forge.train --dev_prefix=./finalTraining300/forge.dev --test_prefix=./finalTraining300/forge.test --out_dir=nmt_model_gnmt_356_0.5 --hparams_path=/NMT/nmt/standard_hparams/forge.json --num_gpus=2 &

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining300/forge.vocab --train_prefix=./finalTraining300/forge.train --dev_prefix=./finalTraining300/forge.dev --test_prefix=./finalTraining300/forge.test --out_dir=nmt_model_335_20 --hparams_path=/NMT/nmt/standard_hparams/forge.bi.json --num_gpus=2 &

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining300/forge.vocab --train_prefix=./finalTraining300/forge.train --dev_prefix=./finalTraining300/forge.dev --test_prefix=./finalTraining300/forge.test --out_dir=nmt_model_412_21 --hparams_path=/NMT/nmt/standard_hparams/forge.bi.json --num_gpus=2 &

nohup python -m nmt.nmt --src=or --tgt=sc --vocab_prefix=./finalTraining300/forge.vocab --train_prefix=./finalTraining300/forge.train --dev_prefix=./finalTraining300/forge.dev --test_prefix=./finalTraining300/forge.test --out_dir=nmt_model_335_22ba --hparams_path=/NMT/nmt/standard_hparams/forge.bi.json --num_gpus=2 &
tokenizer
forgeScribe4.0.sh
for file in *; do echo ""; cat $file; echo ""; read -p "Score: " score; echo "${file}|$score" >> /tmp/scores.csv; done