# Start with the standard Python container
FROM python:3.11-slim

# Update pip and install uv
RUN pip install --upgrade pip && \
    pip install uv

# Install Node.js and npx
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npx

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

# Drop into bash shell to allow calling any of these tools in docker-compose command
CMD ["/bin/bash"]
