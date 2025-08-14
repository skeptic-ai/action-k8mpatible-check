#!/bin/bash
set -e

# Default values
K8S_VERSION="1.28.0"
TOOLS=""
ALL_TOOLS="true"
OUTPUT_FORMAT="table"
FAIL_ON_INCOMPATIBLE="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --k8s-version)
      K8S_VERSION="$2"
      shift 2
      ;;
    --tools)
      TOOLS="$2"
      ALL_TOOLS="false"
      shift 2
      ;;
    --output)
      OUTPUT_FORMAT="$2"
      shift 2
      ;;
    --fail-on-incompatible)
      FAIL_ON_INCOMPATIBLE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Testing K8mpatible Action with:"
echo "  Kubernetes Version: $K8S_VERSION"
if [ -n "$TOOLS" ]; then
  echo "  Tools: $TOOLS"
else
  echo "  All Tools: $ALL_TOOLS"
fi
echo "  Output Format: $OUTPUT_FORMAT"
echo "  Fail on Incompatible: $FAIL_ON_INCOMPATIBLE"
echo ""

# Build the Docker image
echo "Building Docker image..."
docker build -t k8mpatible-action ..

# Run the Docker image
echo "Running Docker image..."
docker run --rm k8mpatible-action "$K8S_VERSION" "$TOOLS" "$ALL_TOOLS" "$OUTPUT_FORMAT" "$FAIL_ON_INCOMPATIBLE"

echo ""
echo "Test completed successfully!"
