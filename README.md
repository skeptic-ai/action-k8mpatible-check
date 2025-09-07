# K8mpatible Compatibility Check Action

This GitHub Action checks the compatibility of Kubernetes tools in your cluster using the [k8mpatible](https://github.com/k8mpatible/k8mpatible) CLI.

## What is k8mpatible?

K8mpatible is a tool that helps you manage all the tools installed in your Kubernetes cluster by checking their version compatibility with your Kubernetes version. It scans your cluster to discover installed tools and checks for incompatibilities that could cause issues.

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
        uses: skeptic-ai/action-k8mpatible-check@v0.1.2
        with:
          kubeconfig: '${{ github.workspace }}/.kube/config'
          output-file: 'compatibility-report.yaml'
          fail-on-incompatible: 'true'
```

## Inputs

| Input                | Description                                                | Required | Default |
|----------------------|------------------------------------------------------------|----------|---------|
| kubeconfig           | Path to kubeconfig file. Leave empty to use default location or in-cluster config | No | "" |
| output-file          | Path to output YAML file for scan results. If not specified, results will only be logged | No | "" |
| fail-on-incompatible | Fail the action if any tool is incompatible                | No       | "true"  |

## Outputs

| Output     | Description                                  |
|------------|----------------------------------------------|
| result     | Compatibility check result                   |
| compatible | Boolean indicating if all tools are compatible |

## How it Works

The action:
1. Connects to your Kubernetes cluster using the provided kubeconfig or in-cluster config
2. Scans the cluster to discover installed tools and their versions
3. Checks for compatibility issues between tools and potential upgrade incompatibilities
4. Outputs results in YAML format to stdout and optionally to a file
5. Fails the action if incompatibilities are found (unless `fail-on-incompatible` is set to false)

## Examples

### Basic Usage (In-Cluster)

```yaml
- name: Check Kubernetes Compatibility
  uses: skeptic-ai/action-k8mpatible-check@v0.1.2
```

### With Custom Kubeconfig

```yaml
- name: Check Kubernetes Compatibility
  uses: skeptic-ai/action-k8mpatible-check@v0.1.2
  with:
    kubeconfig: '${{ github.workspace }}/.kube/config'
```

### Save Results to File

```yaml
- name: Check Kubernetes Compatibility
  uses: skeptic-ai/action-k8mpatible-check@v0.1.2
  with:
    output-file: 'compatibility-report.yaml'

- name: Upload Compatibility Report
  uses: actions/upload-artifact@v4
  with:
    name: compatibility-report
    path: compatibility-report.yaml
```

### Continue on Incompatible

```yaml
- name: Check Kubernetes Compatibility
  id: compatibility
  uses: skeptic-ai/action-k8mpatible-check@v0.1.2
  with:
    fail-on-incompatible: 'false'

- name: Show Warning
  if: steps.compatibility.outputs.compatible == 'false'
  run: echo "::warning::Some tools are incompatible in the cluster"
```

### Complete Workflow with Kubeconfig Setup

```yaml
name: Kubernetes Compatibility Check

on:
  workflow_dispatch:

jobs:
  compatibility-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --region us-west-2 --name my-cluster
          
      - name: Check Kubernetes Compatibility
        uses: skeptic-ai/action-k8mpatible-check@v0.1.2
        with:
          kubeconfig: '${{ env.HOME }}/.kube/config'
          output-file: 'compatibility-report.yaml'

      - name: Upload Compatibility Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: compatibility-report
          path: compatibility-report.yaml
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

# Run with default parameters
./test-action.sh

# Run with custom parameters
./test-action.sh --kubeconfig ~/.kube/config --output-file report.yaml
```

This will build the Docker image and run it with the specified parameters, allowing you to verify that the action works as expected.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.
