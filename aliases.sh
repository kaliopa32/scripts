#!/bin/bash

# Colors
RED='\033[0;31m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
NC='\033[0m'  # No Color

file="${1:-$HOME/.bashrc}"

in_block=false
last_alias_line=0
current_line=0
buffer=()

# read line from bashrc, this IFS loop doesnt remove trailing whitespace as opposed to read -r line
while IFS= read -r line || [[ -n "$line" ]]; do
    ((current_line++))
    trimmed="${line#"${line%%[![:space:]]*}"}"

    if ! $in_block && [[ "$trimmed" =~ ^#.*alias ]]; then
        in_block=true
    fi

    if $in_block; then
        buffer+=("$line")
        [[ "$trimmed" == alias* ]] && last_alias_line=${#buffer[@]}
    fi
done < "$file"

# conditional block for stopping print at last alias, then prints out aliases with color coding
if (( last_alias_line > 0 )); then
    for ((i = 0; i < last_alias_line; i++)); do
        line="${buffer[i]}"
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            echo -e "${GREEN}${line}${NC}"
        elif [[ "$line" =~ ^[[:space:]]*alias[[:space:]]+([^=]+)=(.*) ]]; then
            name="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            echo -e "${RED}alias${NC} ${WHITE}${name}=${value}${NC}"
        else
            echo "$line"
        fi
    done
else
    echo "No alias block found." # print statement for if no aliases are found
fi








































































