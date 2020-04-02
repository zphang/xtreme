#!/bin/bash
# Script to train a model on SQuAD v1.1 or the English TyDiQA-GoldP train data.

REPO=$PWD
MODEL=${1:-bert-base-multilingual-cased}
SRC=${2:-squad}
TGT=${3:-xquad}
GPU=${4:-0}
DATA_DIR=${5:-"$REPO/download/"}
OUT_DIR=${6:-"$REPO/outputs/"}

MAXL=384
LR=3e-5
NUM_EPOCHS=2.0
if [ $MODEL == "bert-base-multilingual-cased" ]; then
  MODEL_TYPE="bert"
elif [ $MODEL == "xlm-mlm-100-1280" ]; then
  MODEL_TYPE="xlm"
elif [ $MODEL == "xlm-roberta-large" ] || [ $MODEL == "xlm-roberta-base" ]; then
  MODEL_TYPE="xlm-roberta"
fi

# Model path where trained model should be stored
MODEL_PATH=$OUT_DIR/$SRC/${MODEL}_LR${LR}_EPOCH${NUM_EPOCHS}_maxlen${MAXL}
mkdir -p $MODEL_PATH 
# Train either on the SQuAD or TyDiQa-GoldP English train file
if [ $SRC == 'squad' ]; then
  TRAIN_FILE=${DATA_DIR}/squad/train-v1.1.json
  PREDICT_FILE=${DATA_DIR}/squad/dev-v1.1.json
else
  TRAIN_FILE=${DATA_DIR}/tydiqa/tydiqa-goldp-v1.1-train/tydiqa.goldp.en.train.json
  PREDICT_FILE=${DATA_DIR}/tydiqa/tydiqa-goldp-v1.1-dev/tydiqa.en.dev.json
fi 

# train
# CUDA_VISIBLE_DEVICES=$GPU python third_party/run_squad.py \
#   --model_type ${MODEL_TYPE} \
#   --model_name_or_path ${MODEL} \
#   --do_lower_case \
#   --do_train \
#   --do_eval \
#   --train_file ${TRAIN_FILE} \
#   --predict_file ${PREDICT_FILE} \
#   --per_gpu_train_batch_size 3 \
#   --learning_rate ${LR} \
#   --num_train_epochs ${NUM_EPOCHS} \
#   --max_seq_length $MAXL \
#   --doc_stride 128 \
#   --save_steps -1 \
#   --overwrite_output_dir \
#   --gradient_accumulation_steps 4 \
#   --warmup_steps 500 \
#   --output_dir ${MODEL_PATH} \
#   --weight_decay 0.0001 \
#   --threads 8 \
#   --train_lang en \
#   --eval_lang en


# predict
bash scripts/predict_qa.sh $MODEL $MODEL_TYPE $MODEL_PATH $TGT $GPU $DATA_DIR