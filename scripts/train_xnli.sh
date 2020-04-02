#!/bin/bash
REPO=$PWD
MODEL=${1:-bert-base-multilingual-cased}
GPU=${2:-0}
DATA_DIR=${3:-"$REPO/download/"}
OUT_DIR=${4:-"$REPO/outputs/"}

export CUDA_VISIBLE_DEVICES=$GPU

TASK='xnli'
LR=2e-5
EPOCH=5
MAXL=128
LANGS="ar,bg,de,el,en,es,fr,hi,ru,sw,th,tr,ur,vi,zh"
LC=""

if [ $MODEL == "bert-base-multilingual-cased" ]; then
  MODEL_TYPE="bert"
elif [ $MODEL == "xlm-mlm-100-1280" ]; then
  MODEL_TYPE="xlm"
  LC=" --do_lower_case"
elif [ $MODEL == "xlm-roberta-large" ]; then
  MODEL_TYPE="xlmr"
fi


SAVE_DIR="$OUT_DIR/$TASK/${MODEL}-LR${LR}-epoch${EPOCH}-MaxLen${MAXL}/"
mkdir -p $SAVE_DIR

python $PWD/third_party/run_classify.py \
  --model_type $MODEL_TYPE \
  --model_name_or_path $MODEL \
  --train_language en \
  --task_name $TASK \
  --do_train \
  --do_eval \
  --do_predict \
  --data_dir $DATA_DIR/${TASK} \
  --gradient_accumulation_steps 4 \
  --per_gpu_train_batch_size 8 \
  --learning_rate $LR \
  --num_train_epochs $EPOCH \
  --max_seq_length $MAXL \
  --output_dir $SAVE_DIR/ \
  --save_steps 100 \
  --eval_all_checkpoints \
  --log_file 'train' \
  --predict_languages $LANGS \
  --save_only_best_checkpoint \
  --overwrite_output_dir \
  --eval_test_set $LC
