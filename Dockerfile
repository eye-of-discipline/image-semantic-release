FROM ubuntu:24.04

ARG NODE_VERSION=24.14.1

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_PATH=/usr/local/lib/node_modules \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        yq \
        openssh-client \
        xz-utils \
    && arch="$(dpkg --print-architecture)" \
    && case "${arch}" in \
        amd64) node_arch=x64 ;; \
        arm64) node_arch=arm64 ;; \
        *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac \
    && node_dist="node-v${NODE_VERSION}-linux-${node_arch}" \
    && curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" \
    && curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/${node_dist}.tar.xz" \
    && grep " ${node_dist}.tar.xz$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "${node_dist}.tar.xz" -C /usr/local --strip-components=1 \
    && rm -f SHASUMS256.txt "${node_dist}.tar.xz" \
    && npm install --global --omit=dev \
        semantic-release@25.0.5 \
        @semantic-release/changelog@6.0.3 \
        @semantic-release/commit-analyzer@13.0.1 \
        @semantic-release/exec@7.1.0 \
        @semantic-release/git@10.0.1 \
        @semantic-release/github@12.0.8 \
        @semantic-release/gitlab@13.3.2 \
        @semantic-release/npm@13.1.5 \
        @semantic-release/release-notes-generator@14.1.1 \
        conventional-changelog-conventionalcommits@9.3.1 \
    && npm cache clean --force \
    && apt-get purge -y --auto-remove xz-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["semantic-release"]
CMD []
