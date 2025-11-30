#!/bin/bash

main() {
    local FILE=$1
    mapfile -t commit_lines < <(git log --oneline --all -- "$FILE" | tac)
    total=${#commit_lines[@]}
    echo "Found $total commits. Starting oldest-first..."

    for line in "${commit_lines[@]}"; do
        commit=$(echo "$line" | cut -d' ' -f1)
        msg=$(echo "$line" | cut -d' ' -f2-)
        echo "Diffing commit: $commit ($msg)"
        if git rev-parse "${commit}^" >/dev/null 2>&1; then
            git difftool "${commit}^" "$commit" -- "$FILE"
        else
            echo "Initial commit—no parent. Skipping diff."
        fi
        # read -p "Press Enter to continue (or Ctrl+C)..."
    done

    read -p "All diffs complete. Press Enter to exit..."
}

FILE=$1
if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>"
    read -p "Press Enter to continue..."
else
    main "$FILE"
fi