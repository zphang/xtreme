#!/bin/bash
REPO=$PWD
MODEL=${1:-bert-base-multilingual-cased}
DATA_DIR=${2:-"$REPO/download/"}

TASK='udpos'
MAXL=128
LANGS='af,ar,bg,de,el,en,es,et,eu,fa,fi,fr,he,hi,hu,id,it,ja,kk,ko,mr,nl,pt,ru,ta,te,th,tl,tr,ur,vi,yo,zh'
LC=""
if [ $MODEL == "bert-base-multilingual-cased" ]; then
  MODEL_TYPE="bert"
elif [ $MODEL == "xlm-mlm-100-1280" ]; then
  MODEL_TYPE="xlm"
  LC=" --do_lower_case"
elif [ $MODEL == "xlm-roberta-large" ] || [ $MODEL == "xlm-roberta-base" ]; then
  MODEL_TYPE="xlmr"
fi

SAVE_DIR="$DATA_DIR/${TASK}/udpos_processed_maxlen${MAXL}"
mkdir -p $SAVE_DIR
python3 $REPO/utils_preprocess.py \
  --data_dir $DATA_DIR/${TASK}/ \
  --task udpos_tokenize \
  --model_name_or_path $MODEL \
  --model_type $MODEL_TYPE \
  --max_len $MAXL \
  --output_dir $SAVE_DIR \
  --languages $LANGS $LC #>> $SAVE_DIR/process.log
cat $SAVE_DIR/*/*.${MODEL_TYPE} | cut -f 2 | grep -v "^$" | sort | uniq > $SAVE_DIR/labels.txt
