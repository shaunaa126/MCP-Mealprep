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
ENV NODE_VERSION 23.11.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && set -ex \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt" \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

ENV YARN_VERSION 1.22.22

RUN set -ex \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz \
  # smoke test
  && yarn --version \
  && rm -rf /tmp/*

# Upgrade pip and install initial tools with extensive debugging
RUN set -x \
    && pip3 install --upgrade pip \
    && pip3 install uv \
    && echo "Pip and uv installation completed" \
    && echo "NPM Global packages installation begins..." \
    && npm install -g c7-mcp-server \
    && echo "Context7 server installed locally"

# Debugging step - list contents of /app to verify file exists
RUN ls -l /app

# Make the script executable
RUN chmod +x /app/startup.sh

# Drop into bash shell
CMD ["/app/startup.sh"]
