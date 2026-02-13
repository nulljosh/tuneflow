#!/bin/bash

# Setup GitHub remotes for all repos in ~/Documents/Code/
# Creates GitHub repos if they don't exist and sets up origin remote

CODE_DIR="$HOME/Documents/Code"

echo "=== Setting up GitHub remotes for all Code projects ==="
echo ""

for dir in "$CODE_DIR"/*/; do
  if [ -d "$dir/.git" ]; then
    repo=$(basename "$dir")
    cd "$dir"

    echo "[$repo]"

    # Check if remote exists
    if ! git remote get-url origin &>/dev/null; then
      echo "  → No remote found. Creating GitHub repo..."

      # Create GitHub repo (private by default)
      if gh repo create "nulljosh/$repo" --private --source=. --remote=origin 2>&1 | grep -q "already exists"; then
        echo "  → Repo exists on GitHub, adding remote..."
        git remote add origin "https://github.com/nulljosh/$repo.git"
      fi

      echo "  ✓ Remote added: https://github.com/nulljosh/$repo"
    else
      remote_url=$(git remote get-url origin)
      echo "  ✓ Remote exists: $remote_url"
    fi

    echo ""
  fi
done

echo "Done! All repos have GitHub remotes configured."
