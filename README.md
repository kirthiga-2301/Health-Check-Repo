# 🩺 Repo Health Checker

A lightweight CI-ready tool that validates repository hygiene using a **Bash script** and **GitHub Actions**. Push your code and get instant feedback on whether your repo follows essential best practices.

---

## 📋 What It Does

`check.sh` runs **four automated validations** every time you push. If any check fails the pipeline exits with code `1`, blocking the build and giving you clear, colour-coded output explaining what went wrong.

---

## ✅ Validation Checks

| # | Check | Why It Matters |
|---|-------|---------------|
| 1 | **README.md exists & has > 5 lines** | A meaningful README is the front door of any project. Sparse or missing documentation discourages contributors and makes onboarding painful. |
| 2 | **.gitignore exists** | Without a `.gitignore`, build artefacts, IDE configs, and dependency folders can pollute the repo, inflating clone times and causing merge noise. |
| 3 | **No `.env` or secret files committed** | Leaking API keys, database credentials, or tokens in version control is a critical security risk that can lead to data breaches. |
| 4 | **Commit messages have > 5 words** | Short, vague messages like "fix" or "update" make `git log` useless. Descriptive messages improve code review, debugging, and project history. |

---

## ⚙️ How GitHub Actions Is Used

The workflow lives at `.github/workflows/check.yml` and is configured to:

1. **Trigger on every push** to any branch — catches problems as early as possible.
2. **Check out the full history** (`fetch-depth: 0`) so the commit-message validation can inspect every commit, not just the latest.
3. **Grant execute permission** to `check.sh` (`chmod +x`).
4. **Run the script** — the exit code determines whether the pipeline passes or fails.

If every check passes, the action shows a green ✅. If any check fails, the action shows a red ❌ with a detailed error message.

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/<your-username>/repo-health-checker.git
cd repo-health-checker

# Run the checks locally
chmod +x check.sh
./check.sh
```

---

## 📁 Project Structure

```
.
├── check.sh                       # Main validation script
├── .github/
│   └── workflows/
│       └── check.yml              # GitHub Actions workflow
├── .gitignore                     # Files & folders excluded from Git
└── README.md                      # This file
```

---

## 🛠️ Extending the Checker

Want to add more checks? Open `check.sh` and follow the existing pattern:

```bash
header "Check N: Your new check"

if [ <condition> ]; then
    fail "Explain what went wrong."
fi

pass "Explain what passed."
```

The script will automatically exit on the first failure and include your new check in the CI pipeline.

---

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
