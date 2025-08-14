FROM alpine:3.19

LABEL org.opencontainers.image.source="https://github.com/k8mpatible/action-k8mpatible-check"
LABEL org.opencontainers.image.description="GitHub Action for checking Kubernetes tools compatibility"
LABEL org.opencontainers.image.licenses="MIT"

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install k8mpatible CLI
RUN LATEST_RELEASE=$(curl -s https://api.github.com/repos/k8mpatible/k8mpatible/releases/latest | jq -r .tag_name) && \
    curl -L "https://github.com/k8mpatible/k8mpatible/releases/download/${LATEST_RELEASE}/k8mpatible_$(echo ${LATEST_RELEASE} | sed 's/^v//')_linux_amd64.tar.gz" -o k8mpatible.tar.gz && \
    tar -xzf k8mpatible.tar.gz && \
    chmod +x k8mpatible && \
    mv k8mpatible /usr/local/bin/ && \
    rm k8mpatible.tar.gz

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
