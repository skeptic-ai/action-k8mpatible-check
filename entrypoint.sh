#!/bin/bash
set -e

# Parse input arguments
KUBERNETES_VERSION="$1"
TOOLS="$2"
ALL_TOOLS="$3"
OUTPUT_FORMAT="$4"
FAIL_ON_INCOMPATIBLE="$5"

echo "::group::K8mpatible Compatibility Check"
echo "Checking compatibility with Kubernetes version: $KUBERNETES_VERSION"

# Prepare command arguments
CMD_ARGS="--k8s-version $KUBERNETES_VERSION --output $OUTPUT_FORMAT"

# Check if specific tools are provided
if [ -n "$TOOLS" ] && [ "$TOOLS" != "" ]; then
  echo "Checking compatibility for tools: $TOOLS"
  TOOLS_ARG=$(echo "$TOOLS" | tr ',' ' ')
  CMD_ARGS="$CMD_ARGS $TOOLS_ARG"
elif [ "$ALL_TOOLS" == "true" ]; then
  echo "Checking compatibility for all supported tools"
else
  echo "No tools specified and all-tools is not true. Please specify tools or set all-tools to true."
  exit 1
fi

# Run k8mpatible compatibility check
echo "Running: k8mpatible check $CMD_ARGS"
RESULT=$(k8mpatible check $CMD_ARGS)
EXIT_CODE=$?

# Output the result
echo "$RESULT"
echo "::endgroup::"

# Set outputs for GitHub Actions
echo "result<<EOF" >> $GITHUB_OUTPUT
echo "$RESULT" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT

# Determine if all tools are compatible
if [ $EXIT_CODE -eq 0 ]; then
  echo "compatible=true" >> $GITHUB_OUTPUT
  echo "All tools are compatible with Kubernetes $KUBERNETES_VERSION"
else
  echo "compatible=false" >> $GITHUB_OUTPUT
  echo "Some tools are incompatible with Kubernetes $KUBERNETES_VERSION"
  
  # Exit with error if fail-on-incompatible is true
  if [ "$FAIL_ON_INCOMPATIBLE" == "true" ]; then
    exit 1
  fi
fi
