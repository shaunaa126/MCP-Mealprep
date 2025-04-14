# Start with the standard Python container
FROM python:3.11-slim

# Ensure apt is updated and install essential build tools
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm using nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 20 \
    && nvm use 20 \
    && npm install -g npx
    
# Update pip and install uv
RUN pip install --upgrade pip && \
    pip install uv

# Install mcpo using pip
RUN pip install mcpo

# Install mcp-proxy using uv tool
RUN uv tool install mcp-proxy

# Install supergateway
RUN npm install -g supergateway

# Optional: Install Superargs (planned improvements)
RUN npm install -g superargs

# Ensure npm and node are in the PATH
ENV PATH="/root/.nvm/versions/node/v20.0.0/bin:${PATH}"

# Set the working directory
WORKDIR /workspace

# Drop into bash shell to allow calling any of these tools in docker-compose command
CMD ["/bin/bash"]
