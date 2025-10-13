#!/usr/bin/env bash
set -euo pipefail

# Discover directories (up to depth 2) that contain a Dockerfile
# and output them as a JSON array suitable for GitHub Actions matrix.
# If $GITHUB_OUTPUT is set, writes images=<json> to it; otherwise prints JSON.

ROOT_DIR="${1:-.}"

# Find directories containing a file named 'Dockerfile', ignore VCS/CI folders
mapfile -t DIRS < <(find "$ROOT_DIR" -maxdepth 2 -type f -name Dockerfile \
  -not -path '*/.git/*' \
  -not -path '*/.github/*' \
  -exec dirname {} \; | sed 's|^\./||' | grep -v '^$')

to_json_shell() {
  if [[ ${#DIRS[@]} -eq 0 ]]; then
    echo '[]'
    return
  fi
  local json="["
  local sep=""
  for d in "${DIRS[@]}"; do
    # minimal JSON string escape for quotes and backslashes
    local e=${d//\\/\\\\}
    e=${e//\"/\\\"}
    json+="$sep\"$e\""
    sep=", "
  done
  json+="]"
  printf '%s' "$json"
}

images_json=$(to_json_shell)

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "images=${images_json}" >> "$GITHUB_OUTPUT"
else
  echo "${images_json}"
fi

