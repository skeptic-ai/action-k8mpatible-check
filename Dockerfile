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
RUN curl -L https://github.com/skeptic-ai/k8mpatible/releases/download/v0.1.5/k8mpatible_0.1.5_Linux_x86_64.tar.gz | tar xz && \
    mv k8mpatible /usr/local/bin/

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
