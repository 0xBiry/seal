#!/usr/bin/env bash
 # Copyright (c), Mysten Labs, Inc.
 # SPDX-License-Identifier: Apache-2.0

 #Script requirements:
 # - git
 # - cargo
 # - jq

 # 🔹 Improvements over your version:
 #1. Check if git, cargo, and jq are installed before running.
 #2. Clear error handling if the script isn't in a Git repository.
 #3. Human-readable returns with ✅ and 📦.
 #4. Use --no-deps to speed up cargo metadata (no need to parse all dependencies).
 #5. Clear message if the crate doesn't exist in the project.

 # Stop the script in case of:
# - an error (set -e)
# - an undefined variable (set -u)
# - a pipeline failure (set -o pipefail)
set -euo pipefail

# Check that all necessary commands are installed
for cmd in git cargo jq; do
if ! command -v "$cmd" >/dev/null 2>&1; then
echo "❌ Error: '$cmd' is not installed or not in the PATH."
exit 1
fi
done

# Go to the root of the Git repository
if git rev-parse --show-toplevel >/dev/null 2>&1; then
cd "$(git rev-parse --show-toplevel)"
else
echo "❌ Error: This folder is not a Git repository."
 exit 1
fi

# Check that an argument is given
if [ $# -lt 1 ]; then
echo "Usage: $0 <crate_name>"
echo "Example: $0 my_crate"
exit 1
fi

CRATE_NAME="$1"

# Get the crate version
VERSION=$(cargo metadata --format-version 1 --no-deps | \
jq --arg crate_name "$CRATE_NAME" -r \
'.packages[] | select(.name == $crate_name) | .version' || true)

# Check if a version was found
if [ -z "$VERSION" ]; then
echo "❌ Error: Crate '$CRATE_NAME' does not exist in this project."
 exit 1
 fi

 echo "✅ Crate: $CRATE_NAME"
 echo "📦 Version: $VERSION"
