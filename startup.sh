#!/bin/bash
set -e

echo "MCP Server Startup Script"
echo "========================="

# Read environment variables or set defaults
MCP_SERVER_TYPE=${MCP_SERVER_TYPE:-"everything"}
MCP_PORT=${MCP_PORT:-8081}
MCP_COMMAND_TYPE=${MCP_COMMAND_TYPE:-"npx"}  # npx, uvx, uv, python
MCP_PACKAGE=${MCP_PACKAGE:-"@modelcontextprotocol/server-everything"}
MCP_ARGS=${MCP_ARGS:-""}
USE_SUPERARGS=${USE_SUPERARGS:-false}

# Function to check if a port is available
check_port_available() {
  local port=$1
  if nc -z localhost "$port" 2>/dev/null; then
    return 0 # Port is in use
  else
    return 1 # Port is free
  fi
}

# Function to check dependency readiness using curl
check_dependency_ready() {
  local port=$1
  local timeout=30
  local retries=5
  local delay=2

  echo "Checking if service on port $port is ready..."

  for i in $(seq 1 $retries); do
    if curl -s --fail http://localhost:"$port" > /dev/null; then
      echo "Service on port $port is ready."
      return 0 # Success
    else
      echo "Attempt $i failed. Waiting $delay seconds..."
      sleep "$delay"
    fi
  done

  echo "Failed to connect to service on port $port after $retries attempts."
  return 1 # Failure
}


# Build the MCP server command based on type
SERVER_CMD=""
case "$MCP_COMMAND_TYPE" in
  "npx")
    SERVER_CMD="npx -y ${MCP_PACKAGE}"
    ;;
  "uvx")
    SERVER_CMD="uvx ${MCP_PACKAGE}"
    ;;
  "uv")
    SERVER_CMD="uv ${MCP_PACKAGE}"
    ;;
  "python3")
    SERVER_CMD="${MCP_PACKAGE}"
    ;;
  *)
    echo "Unknown command type: ${MCP_COMMAND_TYPE}"
    exit 1
    ;;
esac

# Launching MCP Server (Conditional based on USE_SUPERARGS):
echo "Launching MCP Server (Type: $MCP_SERVER_TYPE, Port: $MCP_PORT)"
if [ "$USE_SUPERARGS" = "true" ]; then
  echo "Superargs logic removed for simplicity."
else
  eval "${SERVER_CMD} ${MCP_ARGS}"
fi

# Launch Supergateway
echo "Launching Supergateway (Port: $MCP_PORT)"
npx -y supergateway \
    --stdio "$SERVER_CMD ${MCP_ARGS}" \
    --port "$MCP_PORT" --baseUrl http://localhost:"$MCP_PORT" \
    --outputTransport streamableHttp --streamableHttpPath /mcp --stateful --sessionTimeout 60000 --healthEndpoint /healthz

# Launch MCPO
echo "Launching mcpo"
if [ "$USE_MCPO" = "true" ]; then
  echo "Using mcpo to duplicate MCP server and provide OpenAPI endpoint on same port."
  uvx mcpo --port $MCP_PORT --api-key "${MCP_ARGS}" -- $SERVER_CMD
else
  echo "Skipping mcpo install for ${MCP_SERVER_TYPE container"
fi

# Run mcp-shield utility and redirect the output to the log file
npx mcp-shield >> "mcp-shield.log" 2>&1
echo "mcp-shield utility ran, see log for more info"

echo "Startup complete."
