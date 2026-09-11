# A Fountain runner in a container. The sandboxes are directories in here, not on the laptop.
# What a runner machine needs (Fountain docs, runners.md): bash, git, node/npm/npx, bun. Plus the lessons' tools:
# the AWS CLI and jq for reading an account, terraform for the desk's plan and apply.
#
# The fountain CLI is copied from bin/, built from a Fountain checkout because the runner
# command is newer than the last released binary:
#   cd <fountain>/cli && GOOS=linux GOARCH=amd64 go build -o bin/fountain-linux-amd64 ./cmd/fountain
# Prebuilt image: ghcr.io/intentius/waterpark-runner
FROM node:22-bookworm-slim
ARG TARGETARCH
# Terraform is the applier the AWS desk runs (decision 31). Pinned to the version
# the course checkpoints were cut with, so a sandbox and the author agree.
ARG TERRAFORM_VERSION=1.15.8
# The access repo's rule pack is Rego on tflint's opa plugin. Both are here so
# a sandbox lints without a network round trip on its first plan.
ARG TFLINT_VERSION=0.59.1
ARG TFLINT_OPA_VERSION=0.8.0
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git jq unzip bash openssh-client less groff \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash >/dev/null \
 && ARCH=$([ "${TARGETARCH:-amd64}" = "arm64" ] && echo aarch64 || echo x86_64) \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install >/dev/null && rm -rf /tmp/aws /tmp/awscli.zip \
 && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH:-amd64}.zip" -o /tmp/terraform.zip \
 && unzip -q /tmp/terraform.zip -d /usr/local/bin && rm /tmp/terraform.zip && chmod +x /usr/local/bin/terraform \
 && curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${TARGETARCH:-amd64}.zip" -o /tmp/tflint.zip \
 && unzip -q /tmp/tflint.zip -d /usr/local/bin && rm /tmp/tflint.zip && chmod +x /usr/local/bin/tflint
COPY bin/fountain-linux-${TARGETARCH:-amd64} /usr/local/bin/fountain
RUN chmod +x /usr/local/bin/fountain && useradd -m -s /bin/bash runner && mkdir -p /sandboxes && chown runner:runner /sandboxes
# The opa plugin goes somewhere every sandbox can see. A sandbox runs with its
# own directory as HOME, so a plugin installed under /home/runner is a plugin
# nobody finds, and every first lint would go and fetch it again.
ENV TFLINT_PLUGIN_DIR=/opt/tflint-plugins
RUN mkdir -p /tmp/tflint-init "$TFLINT_PLUGIN_DIR" \
 && printf 'plugin "opa" {\n  enabled = true\n  version = "%s"\n  source  = "github.com/terraform-linters/tflint-ruleset-opa"\n}\n' "${TFLINT_OPA_VERSION}" > /tmp/tflint-init/.tflint.hcl \
 && cd /tmp/tflint-init && tflint --init && rm -rf /tmp/tflint-init \
 && chmod -R a+rX "$TFLINT_PLUGIN_DIR"
USER runner
ENV HOME=/home/runner PATH=/usr/local/bin:/usr/local/aws-cli/v2/current/bin:$PATH
WORKDIR /sandboxes
