#!/bin/bash

set -e

TARGET_NAME="RelayCoreTests"
BUILD_DIR=".build/debug"
PROFILE_DATA="$BUILD_DIR/codecov/default.profdata"
TEST_BINARY="$BUILD_DIR/${TARGET_NAME}.xctest/Contents/MacOS/${TARGET_NAME}"

echo "🧪 Running tests with coverage enabled..."
swift test --enable-code-coverage

echo "📊 Generating coverage report..."
xcrun llvm-cov report \
  "$TEST_BINARY" \
  -instr-profile "$PROFILE_DATA"

echo ""
echo "📂 To view detailed file-level coverage, run:"
echo "xcrun llvm-cov show $TEST_BINARY -instr-profile $PROFILE_DATA"