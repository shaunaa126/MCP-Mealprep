# Start with buildpack-deps (Debian-based) from 
FROM buildpack-deps:bullseye

# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Rest of node install taken from nodejs/docker-node:Dockerfile-debian.template
# Create a node group and user
RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Install Node.js 
ENV NODE_VERSION 20.11.1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
       amd64) ARCH='x64';; \
       arm64) ARCH='arm64';; \
       *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Upgrade pip and install initial tools with extensive debugging
RUN set -x \
    && pip3 install --upgrade pip \
    && pip3 install uv \
    && echo "Pip and uv installation completed" \
    && echo "NPM Global packages installation begins..." \
    && npm install -g npx supergateway superargs \
    && echo "NPM Global packages installed successfully" \

# Set up virtual environment for mcpo
ENV VIRTUAL_ENV=/app/.venv
WORKDIR /app

# Create virtual environment for mcpo
RUN python3 -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install mcpo and dependencies
RUN pip3 install . \
    && rm -rf ~/.cache

# Verify installations
RUN which mcpo \
    && mcpo --version

# Drop into bash shell
CMD ["/bin/bash"]
