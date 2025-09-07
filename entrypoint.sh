#!/bin/bash
# Note: We don't use 'set -e' here because k8mpatible may exit with code 1 
# when incompatibilities are found, and we want to handle that gracefully

# Parse input arguments
KUBECONFIG_PATH="$1"
OUTPUT_FILE="$2"
FAIL_ON_INCOMPATIBLE="$3"

echo "::group::K8mpatible Compatibility Check"
echo "Running k8mpatible compatibility scan..."

# Debug: Check if k8mpatible binary exists and is executable
if ! command -v k8mpatible &> /dev/null; then
  echo "❌ Error: k8mpatible binary not found in PATH"
  exit 1
fi

echo "✅ k8mpatible binary found: $(which k8mpatible)"

# Debug: Check kubernetes connectivity
echo "🔍 Testing Kubernetes connectivity..."
if kubectl cluster-info &> /dev/null; then
  echo "✅ Kubernetes cluster is accessible"
  kubectl get nodes --no-headers 2>/dev/null | wc -l | xargs echo "📊 Cluster has" | xargs echo "nodes"
else
  echo "❌ Warning: Cannot connect to Kubernetes cluster"
  echo "This may cause the scan to hang or fail"
fi

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
echo "Starting scan..."

# Run with timeout to prevent hanging
timeout 300 k8mpatible $CMD_ARGS > /tmp/k8mpatible_output.txt 2>&1
EXIT_CODE=$?

# Check if command timed out
if [ $EXIT_CODE -eq 124 ]; then
  echo "❌ k8mpatible scan timed out after 5 minutes"
  RESULT="Error: k8mpatible scan timed out after 5 minutes. This may indicate cluster connectivity issues or a large number of resources to scan."
  EXIT_CODE=1
else
  # Read the output
  RESULT=$(cat /tmp/k8mpatible_output.txt)
  echo "Scan completed with exit code: $EXIT_CODE"
fi

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
