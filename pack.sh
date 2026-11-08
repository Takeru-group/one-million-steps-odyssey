#!/bin/bash
set -e

echo "📦 Repomix を実行して軽量コードパックを作成中..."
npx repomix --config repomix.config.json

if [ -f "repomix-output.xml" ]; then
  FILE_SIZE=$(ls -lh repomix-output.xml | awk '{print $5}')
  LINE_COUNT=$(wc -l < repomix-output.xml | tr -d ' ')
  echo "✅ 完了: repomix-output.xml (サイズ: $FILE_SIZE, 行数: $LINE_COUNT 行)"
fi
