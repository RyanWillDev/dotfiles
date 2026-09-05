#!/bin/bash
# Claude Code status line: model name, context usage progress bar, and total
# tokens in context.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

total_tokens=$((total_input + total_output))

# Thousands-separated token count (fall back to plain number if the locale
# printf can't group digits).
formatted_tokens=$(printf "%'d" "$total_tokens" 2>/dev/null)
[ -z "$formatted_tokens" ] && formatted_tokens="$total_tokens"

# Build a 20-cell progress bar for context used_percentage.
bar_width=20
if [ -n "$used_pct" ]; then
  filled=$(awk -v p="$used_pct" -v w="$bar_width" \
    'BEGIN { f = int((p * w / 100) + 0.5); if (f > w) f = w; if (f < 0) f = 0; print f }')
  pct_display=$(awk -v p="$used_pct" 'BEGIN { printf "%.0f", p }')
else
  filled=0
  pct_display=0
fi
empty=$((bar_width - filled))

# Color the bar by usage level: green < 60%, yellow < 85%, red >= 85%.
if [ "$pct_display" -ge 85 ]; then
  bar_color="\033[31m"
elif [ "$pct_display" -ge 60 ]; then
  bar_color="\033[33m"
else
  bar_color="\033[32m"
fi
reset="\033[0m"
dim="\033[2m"

bar=""
i=0
while [ "$i" -lt "$filled" ]; do bar="${bar}#"; i=$((i + 1)); done
i=0
while [ "$i" -lt "$empty" ]; do bar="${bar}."; i=$((i + 1)); done

printf "${dim}%s${reset} ${bar_color}[%s]${reset} %s%% ${dim}(%s tok)${reset}\n" \
  "$model" "$bar" "$pct_display" "$formatted_tokens"
