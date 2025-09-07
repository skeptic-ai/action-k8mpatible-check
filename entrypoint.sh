#!/bin/bash
set -e

# Parse input arguments
KUBECONFIG_PATH="$1"
OUTPUT_FILE="$2"
FAIL_ON_INCOMPATIBLE="$3"

echo "::group::K8mpatible Compatibility Check"
echo "Running k8mpatible compatibility scan..."

# Prepare command arguments
CMD_ARGS=""

# Add kubeconfig path if provided
if [ -n "$KUBECONFIG_PATH" ] && [ "$KUBECONFIG_PATH" != "" ]; then
  echo "Using kubeconfig: $KUBECONFIG_PATH"
  CMD_ARGS="$CMD_ARGS --kubeconfig $KUBECONFIG_PATH"
else
  echo "Using default kubeconfig location or in-cluster config"
fi

# Add output file if provided
if [ -n "$OUTPUT_FILE" ] && [ "$OUTPUT_FILE" != "" ]; then
  echo "Output will be saved to: $OUTPUT_FILE"
  CMD_ARGS="$CMD_ARGS --output $OUTPUT_FILE"
else
  echo "Output will only be logged to stdout"
fi

# Run k8mpatible scan
echo "Running: k8mpatible $CMD_ARGS"
RESULT=$(k8mpatible $CMD_ARGS 2>&1)
EXIT_CODE=$?

# Output the result with clear section header
echo ""
echo "📋 Compatibility Scan Results:"
echo "================================"
echo "$RESULT"
echo "================================"
echo "::endgroup::"

# Set outputs for GitHub Actions
echo "result<<EOF" >> $GITHUB_OUTPUT
echo "$RESULT" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT

# Determine if all tools are compatible based on exit code
if [ $EXIT_CODE -eq 0 ]; then
  echo "compatible=true" >> $GITHUB_OUTPUT
  echo "✅ No incompatibilities found in cluster"
else
  echo "compatible=false" >> $GITHUB_OUTPUT
  echo "❌ Incompatibilities found in cluster"
  
  # Exit with error if fail-on-incompatible is true (default)
  if [ "$FAIL_ON_INCOMPATIBLE" != "false" ]; then
    echo "Action failed due to incompatibilities"
    exit 1
  else
    echo "Action completed with incompatibilities (fail-on-incompatible is disabled)"
  fi
fi
