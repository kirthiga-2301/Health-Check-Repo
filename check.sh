#!/bin/bash

# ============================================================
#  Repo Health Checker — check.sh
#  Validates repository quality and hygiene before merge / deploy.
# ============================================================

set -euo pipefail

# ── Formatting helpers ──────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'  # No Color

pass() { echo -e "  ${GREEN}✔ PASS${NC}  $1"; }
fail() { echo -e "  ${RED}✘ FAIL${NC}  $1"; exit 1; }
header() { echo -e "\n${CYAN}${BOLD}── $1 ──${NC}"; }

# ── Track overall status ────────────────────────────────────
echo -e "\n${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║      Repo Health Checker  v1.0       ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"

# ────────────────────────────────────────────────────────────
# CHECK 1 — README.md exists and has more than 5 lines
# ────────────────────────────────────────────────────────────
header "Check 1: README.md"

if [ ! -f "README.md" ]; then
    fail "README.md does not exist."
fi

LINE_COUNT=$(wc -l < README.md)
if [ "$LINE_COUNT" -le 5 ]; then
    fail "README.md has only ${LINE_COUNT} line(s). It must have more than 5."
fi

pass "README.md exists and has ${LINE_COUNT} lines."

# ────────────────────────────────────────────────────────────
# CHECK 2 — .gitignore file exists
# ────────────────────────────────────────────────────────────
header "Check 2: .gitignore"

if [ ! -f ".gitignore" ]; then
    fail ".gitignore file is missing."
fi

pass ".gitignore file exists."

# ────────────────────────────────────────────────────────────
# CHECK 3 — No .env or secret files committed
# ────────────────────────────────────────────────────────────
header "Check 3: Secret / .env files"

# Patterns that should never appear in the tracked tree
SECRET_PATTERNS=(".env" ".env.local" ".env.production" ".env.staging"
                 "secrets.yml" "secrets.yaml" "secrets.json"
                 ".secret" "credentials.json" "service-account.json")

for pattern in "${SECRET_PATTERNS[@]}"; do
    # Search tracked files (git ls-files) for exact basename matches
    if git ls-files --error-unmatch "$pattern" > /dev/null 2>&1; then
        fail "Sensitive file '${pattern}' is tracked by Git. Remove it and add to .gitignore."
    fi
done

pass "No .env or secret files found in the repository."

# ────────────────────────────────────────────────────────────
# CHECK 4 — All commit messages have more than 5 words
# ────────────────────────────────────────────────────────────
header "Check 4: Commit message quality"

# Retrieve every commit message on the current branch
COMMIT_MESSAGES=$(git log --format='%s' 2>/dev/null || true)

if [ -z "$COMMIT_MESSAGES" ]; then
    pass "No commits found (new repository). Skipping message check."
else
    FAIL_FOUND=0
    while IFS= read -r msg; do
        WORD_COUNT=$(echo "$msg" | wc -w)
        if [ "$WORD_COUNT" -le 5 ]; then
            echo -e "    ${RED}→${NC} \"${msg}\" (${WORD_COUNT} words)"
            FAIL_FOUND=1
        fi
    done <<< "$COMMIT_MESSAGES"

    if [ "$FAIL_FOUND" -eq 1 ]; then
        fail "One or more commit messages have 5 or fewer words. Use descriptive messages."
    fi

    pass "All commit messages contain more than 5 words."
fi

# ────────────────────────────────────────────────────────────
# SUMMARY
# ────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}All checks passed — repository is healthy! 🎉${NC}"
echo ""
exit 0
