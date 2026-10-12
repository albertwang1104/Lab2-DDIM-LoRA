#!/usr/bin/env bash
set -euo pipefail

# ====== 依你的實際路徑修改這兩個 ======
CKPT="results/pred_noise_beta_linear.ckpt"     # <-- 換成你的 checkpoint 路徑
OUT_ROOT="results/samples"           # <-- 所有結果的根目錄
# =====================================

DDIM_STEPS_LIST=(10 20 50 100 1000)
ETA_LIST=(0.0 0.2 0.5 1.0)

mkdir -p "$OUT_ROOT"

for steps in "${DDIM_STEPS_LIST[@]}"; do
  for eta in "${ETA_LIST[@]}"; do
    save_dir="${OUT_ROOT}/steps${steps}_eta${eta}"
    mkdir -p "$save_dir"

    echo "=============================================="
    echo ">> DDIM_STEPS=${steps}  ETA=${eta}"
    echo ">> save_dir=${save_dir}"
    echo "=============================================="

    python sampling.py \
      --ckpt_path "$CKPT" \
      --save_dir "$save_dir" \
      --sample_method ddim \
      --ddim_steps "$steps" \
      --eta "$eta"
  done
done

echo "全部組合完成，結果在 ${OUT_ROOT}/"