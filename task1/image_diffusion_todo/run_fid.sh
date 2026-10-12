#!/usr/bin/env bash
set -uo pipefail

# ====== 依實際路徑修改 ======
EVAL_DIR="data/afhq/eval"               # 參考(真實)影像資料夾
SAMPLE_ROOT="results/samples"        # 上一步 sampling 的輸出根目錄
RESULT_TXT="fid_results.txt"            # FID 紀錄檔
# ===========================

# 初始化結果檔(含表頭與時間)
{
  echo "# FID results"
  echo "# generated at: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "# eval_dir: ${EVAL_DIR}"
  printf "%-30s %s\n" "sample_dir" "FID"
  echo "----------------------------------------------"
} > "$RESULT_TXT"

# 逐一跑每個 sample 子資料夾(排序後)
for sample_dir in $(ls -d "${SAMPLE_ROOT}"/*/ 2>/dev/null | sort); do
  name=$(basename "$sample_dir")
  echo "=============================================="
  echo ">> measuring FID for: ${name}"
  echo "=============================================="

  # 跑 FID，完整輸出同時印在螢幕並存進暫存
  out=$(python fid/measure_fid.py "$EVAL_DIR" "$sample_dir" 2>&1)
  echo "$out"

  # 從輸出抓出 FID 數值(抓最後一個浮點數，容錯不同印法)
  fid=$(echo "$out" | grep -oiE 'fid[^0-9]*[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+' | tail -n1)
  if [ -z "$fid" ]; then
    fid=$(echo "$out" | grep -oE '[0-9]+\.[0-9]+' | tail -n1)   # 退而求其次
  fi
  [ -z "$fid" ] && fid="PARSE_FAILED"

  printf "%-30s %s\n" "$name" "$fid" >> "$RESULT_TXT"
done

echo ""
echo "全部完成，結果寫入 ${RESULT_TXT}："
cat "$RESULT_TXT"