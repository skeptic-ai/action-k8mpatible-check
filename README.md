# K8mpatible Compatibility Check Action

This GitHub Action checks the compatibility of Kubernetes tools with a specific Kubernetes version using the [k8mpatible](https://github.com/k8mpatible/k8mpatible) CLI.

## What is k8mpatible?

K8mpatible is a tool that helps you manage all the tools installed in your Kubernetes cluster by checking their version compatibility with your Kubernetes version. It helps prevent issues caused by incompatible tool versions before they happen.

## Usage

```yaml
name: Kubernetes Compatibility Check

on:
  pull_request:
    paths:
      - 'kubernetes/**'
      - 'helm/**'
  workflow_dispatch:

jobs:
  compatibility-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check Kubernetes Compatibility
        uses: k8mpatible/action-k8mpatible-check@v1
        with:
          kubernetes-version: '1.28.0'
          tools: 'cert-manager,istio,external-secrets'
          output-format: 'table'
          fail-on-incompatible: 'true'
```

## Inputs

| Input                | Description                                                | Required | Default |
|----------------------|------------------------------------------------------------|----------|---------|
| kubernetes-version   | Kubernetes version to check compatibility against          | Yes      | -       |
| tools                | Comma-separated list of tools to check                     | No       | ""      |
| all-tools            | Check all supported tools                                  | No       | "true"  |
| output-format        | Output format (json, yaml, table)                          | No       | "table" |
| fail-on-incompatible | Fail the action if any tool is incompatible                | No       | "true"  |

**Note**: You must either specify `tools` or set `all-tools` to "true".

## Outputs

| Output     | Description                                  |
|------------|----------------------------------------------|
| result     | Compatibility check result                   |
| compatible | Boolean indicating if all tools are compatible |

## Examples

### Check Specific Tools

```yaml
- name: Check Kubernetes Compatibility
  uses: k8mpatible/action-k8mpatible-check@v1
  with:
    kubernetes-version: '1.28.0'
    tools: 'cert-manager,istio,external-secrets'
    all-tools: 'false'
```

### Check All Tools

```yaml
- name: Check Kubernetes Compatibility
  uses: k8mpatible/action-k8mpatible-check@v1
  with:
    kubernetes-version: '1.28.0'
    all-tools: 'true'
```

### Output as JSON

```yaml
- name: Check Kubernetes Compatibility
  uses: k8mpatible/action-k8mpatible-check@v1
  with:
    kubernetes-version: '1.28.0'
    output-format: 'json'
```

### Continue on Incompatible

```yaml
- name: Check Kubernetes Compatibility
  id: compatibility
  uses: k8mpatible/action-k8mpatible-check@v1
  with:
    kubernetes-version: '1.28.0'
    fail-on-incompatible: 'false'

- name: Show Warning
  if: steps.compatibility.outputs.compatible == 'false'
  run: echo "::warning::Some tools are incompatible with Kubernetes 1.28.0"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Local Development and Testing

You can test the action locally before pushing to GitHub using the provided test script:

```bash
# Navigate to the scripts directory
cd scripts

# Make the script executable (if not already)
chmod +x test-action.sh

# Run with default parameters (Kubernetes 1.28.0, all tools)
./test-action.sh

# Run with custom parameters
./test-action.sh --k8s-version 1.27.0 --tools "cert-manager,istio" --output json
```

This will build the Docker image and run it with the specified parameters, allowing you to verify that the action works as expected.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.
