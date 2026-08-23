# A Fountain runner in a container. The sandboxes are directories in here, not on the laptop.
# What a runner machine needs (Fountain docs, runners.md): bash, git, node/npm/npx, bun. Plus the lessons' tools.
#
# The fountain CLI is copied from bin/, built from a Fountain checkout because the runner
# command is newer than the last released binary:
#   cd <fountain>/cli && GOOS=linux GOARCH=amd64 go build -o bin/fountain-linux-amd64 ./cmd/fountain
# Prebuilt image: ghcr.io/intentius/waterpark-runner
FROM node:22-bookworm-slim
ARG TARGETARCH
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git jq unzip bash openssh-client less groff \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash >/dev/null \
 && ARCH=$([ "${TARGETARCH:-amd64}" = "arm64" ] && echo aarch64 || echo x86_64) \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install >/dev/null && rm -rf /tmp/aws /tmp/awscli.zip
COPY bin/fountain-linux-${TARGETARCH:-amd64} /usr/local/bin/fountain
RUN chmod +x /usr/local/bin/fountain && useradd -m -s /bin/bash runner && mkdir -p /sandboxes && chown runner:runner /sandboxes
USER runner
WORKDIR /sandboxes
ENV HOME=/home/runner PATH=/usr/local/bin:/usr/local/aws-cli/v2/current/bin:$PATH
