#!/bin/bash
set -e

echo "🔧 Setting up Relay project..."

echo "➡️ Configuring pre-commit hooks"
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit

echo "➡️ Checking tool dependencies"
brew list swiftlint &>/dev/null || brew install swiftlint
brew list swiftformat &>/dev/null || brew install swiftformat

echo "✅ Done! You're ready to build and test 🚀"
