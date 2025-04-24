# Start with buildpack-deps (Debian-based) from 
FROM buildpack-deps:bullseye

# Create Workdirectory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app/

# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    python3-pip \
    python3-venv \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install uv CLI
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

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
    && npm install -g c7-mcp-server \
    $$ echo "Context7 server installed locally"

# Debugging step - list contents of /app to verify file exists
RUN ls -l /app

# Make the script executable
RUN chmod +x /app/startup.sh

# Drop into bash shell
CMD ["/app/startup.sh"]
