# Start with buildpack-deps (Debian-based) from 
FROM buildpack-deps:bullseye

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

# Update pip and install uv
RUN apt-get update && apt-get install -y python3-pip \
    && pip install --upgrade pip \
    && pip install uv

# Install mcpo using pip
RUN pip install mcpo

# Install mcp-proxy using uv tool
RUN uv tool install mcp-proxy

# Install supergateway
RUN npm install -g supergateway

# Optional: Install Superargs (planned improvements)
RUN npm install -g superargs

# Set the working directory
WORKDIR /workspace

# Drop into bash shell
CMD ["/bin/bash"]
# Set the working directory
WORKDIR /workspace

# Drop into bash shell to allow calling any of these tools in docker-compose command
CMD ["/bin/bash"]
