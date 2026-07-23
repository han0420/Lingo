#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
mapfile_compat() { while IFS= read -r line; do [[ -n "$line" ]] && FILES+=("$line"); done; }
FILES=()
mapfile_compat < <(find . -type f -not -path './.build/*' -not -path './dist/*' -not -path './.git/*' -print | sed 's#^./##')

for file in "${FILES[@]}"; do
  case "/$file" in
    */.env|*/.env.*|*.p8|*.p12|*.pem|*.key|*.mobileprovision) echo "blocked sensitive file: $file" >&2; exit 1 ;;
  esac
done

SCAN_FILES=()
for file in "${FILES[@]}"; do
  [[ "$file" == "script/security_check.sh" ]] || SCAN_FILES+=("$file")
done

if rg -n --no-messages -e '/Users/' -e 'sk-(proj-)?[A-Za-z0-9_-]{16,}' -e 'BEGIN ([A-Z ]+)?PRIVATE KEY' "${SCAN_FILES[@]}"; then
  echo "possible secret or personal data found" >&2
  exit 1
fi
echo "security audit: passed (${#FILES[@]} files checked)"
