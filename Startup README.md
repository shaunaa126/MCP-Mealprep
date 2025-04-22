# Startup README for startup.sh

Okay, here's a line-by-line walkthrough of the startup.sh script:

1. #!/bin/bash: Shebang line - specifies that the script should be executed using the Bash interpreter.
2. set -e: Ensures that the script exits immediately if any command fails (returns a non-zero exit code). This is good practice for error handling.

## Variable Initialization (Default Values):

8. MCP_SERVER_TYPE=${MCP_SERVER_TYPE:-"everything"}: Sets the MCP_SERVER_TYPE variable to its value if it's already defined in the environment; otherwise, defaults to "everything". The ${variable:-default} syntax is a Bash parameter expansion that provides a default value.
9. MCP_PORT=${MCP_PORT:-8001}: Similar to above, sets MCP_PORT to 8001 if not already defined.
10. MCP_COMMAND_TYPE=${MCP_COMMAND_TYPE:-"npx"}: Sets MCP_COMMAND_TYPE to "npx" by default. This determines how the MCP server is launched (e.g., npx, uvx, uv, python).
11. MCP_PACKAGE=${MCP_PACKAGE:-"@modelcontextprotocol/server-everything"}: Sets MCP_PACKAGE to "@modelcontextprotocol/server-everything" by default. This specifies the package name for the MCP server.
12. MCP_ARGS=${MCP_ARGS:-""}: Sets MCP_ARGS to an empty string if not already defined, allowing for additional arguments to be passed to the server.
13. USE_SUPERARGS=${USE_SUPERARGS:-false}: Sets USE_SUPERARGS to false by default. This flag controls whether a more complex argument parsing method (using superargs) is used.

## Function Definitions:

16. check_port_available() { ... }: Defines a function named check_port_available.

local port=$1: Assigns the first argument passed to the function ($1) to the local variable port.
if nc -z localhost "$port" 2>/dev/null; then ... else ... fi: Checks if a TCP connection can be established to localhost on the specified port. nc -z attempts a zero-I/O connection (just checks for open port). 2>/dev/null redirects standard error to /dev/null, suppressing any error messages from nc.
return 0: Returns an exit code of 0 if the port is in use.
return 1: Returns an exit code of 1 if the port is free.

26. check_dependency_ready() { ... }: Defines a function named check_dependency_ready.

local port=$1: Assigns the first argument to the local variable port.
local timeout=30: Sets a timeout value of 30 seconds.
local retries=5: Sets the number of retry attempts to 5.
local delay=2: Sets the delay between retry attempts to 2 seconds.
echo "Checking if service on port $port is ready...": Prints a message indicating that the dependency check is starting.
for i in $(seq 1 $retries); do ... done: Loops retries number of times.
if curl -s --fail http://localhost:"$port" > /dev/null; then ... else ... fi: Attempts to make an HTTP request to the specified port using curl. -s makes curl silent (suppresses progress meter and error messages). --fail causes curl to exit with a non-zero status code if the request fails. The output is redirected to /dev/null.
echo "Service on port $port is ready.": Prints a success message if the curl command succeeds.
return 0: Returns an exit code of 0 (success).
echo "Attempt $i failed. Waiting $delay seconds...": Prints a message indicating that the attempt failed and is retrying.
sleep "$delay": Pauses execution for delay seconds.
echo "Failed to connect to service on port $port after $retries attempts.": Prints an error message if all retry attempts fail.
return 1: Returns an exit code of 1 (failure).

## Building the Server Command:

50. SERVER_CMD="": Initializes an empty variable SERVER_CMD.
51. case "$MCP_COMMAND_TYPE" in ... esac: A case statement that determines the command to launch the MCP server based on the value of MCP_COMMAND_TYPE.
"npx") SERVER_CMD="npx -y ${MCP_PACKAGE}";;: If MCP_COMMAND_TYPE is "npx", sets SERVER_CMD to npx -y ${MCP_PACKAGE}.
"uvx") SERVER_CMD="uvx ${MCP_PACKAGE}";;: If MCP_COMMAND_TYPE is "uvx", sets SERVER_CMD to uvx ${MCP_PACKAGE}.
"uv") SERVER_CMD="uv ${MCP_PACKAGE}";;: If MCP_COMMAND_TYPE is "uv", sets SERVER_CMD to uv ${MCP_PACKAGE}.
"python") SERVER_CMD="${MCP_PACKAGE}";;: If MCP_COMMAND_TYPE is "python3", sets SERVER_CMD to ${MCP_PACKAGE}.
*) echo "Unknown command type: ${MCP_COMMAND_TYPE}" ; exit 1;;: If MCP_COMMAND_TYPE doesn't match any of the above cases, prints an error message and exits the script with a non-zero exit code.

## Launching MCP Server (Conditional based on USE_SUPERARGS):

71. echo "Launching MCP Server (Type: $MCP_SERVER_TYPE, Port: $MCP_PORT)": Prints a message indicating that the MCP server is being launched.

if [ "$USE_SUPERARGS" = "true" ]; then ... else ... fi: Conditional block based on the value of USE_SUPERARGS.

If USE_SUPERARGS is true: echo "Superargs logic removed for simplicity."

The code here is a bit of a placeholder to be replaced with superargs functionality sometime in the future

75. eval "${SERVER_CMD} ${MCP_ARGS}": Executes the command stored in SERVER_CMD, followed by any additional arguments specified in MCP_ARGS. The eval command is used to interpret the string as a shell command. This launches the MCP server and all args necessary to run, as passed in the environment variables from the docker-compose.

## Launching Supergateway:

79. echo "Launching Supergateway (Port: $MCP_PORT)": Prints a message indicating that Supergateway is being launched.

80. npx -y supergateway --stdio "$SERVER_CMD ${MCP_ARGS}" --port "$MCP_PORT" --baseUrl http://localhost:"$MCP_PORT" --ssePath /sse --messagePath /message: Launches Supergateway using npx. It passes the MCP server command (SERVER_CMD) and its arguments (MCP_ARGS) to Supergateway via the --stdio option. It also sets the port, base URL, SSE path, and message path for Supergateway.

This makes sure the MCP surver is connected to the correct port for internal traffic on STDIO/STDOUT and on SSE/Messages traffic. This will allow you to safely expose this container and external port for AI/LLM clients.

## Launching mcpo:

86. echo "Launching mcpo"  Prints a message indicating that the mcpo server/service is being launched. This will install and run a duplicate MCP server, as best I can tell. But it allows for everything to run on the same port and defaults to automatic functionality with OpenWebUI through an OpenAPI that's searchable at /docs. I'm not sure what'll win, but I made this deactivated but available if you want. 
87. if [ "$USE_MCPO" = "true" ]; then  Checks Environment variables for "USE_MCPO=true"
  echo "Using mcpo to duplicate MCP server and provide OpenAPI endpoint on same port."
  uvx mcpo --port $MCP_PORT --api-key "${MCP_ARGS}" -- $SERVER_CMD
else
  echo "Skipping mcpo install for ${MCP_SERVER_TYPE container"
fi 

## Scanning security with mcp-shield
95. npx mcp-shield >> "mcp-shield.log" 2>&1  runs the mcp security scanner [mcp-shield](https://github.com/riseandignite/mcp-shield) and appends to the logfile
echo "mcp-shield utility ran, see log for more info"

echo "Startup complete.": Prints a message indicating that the startup process is complete.

This detailed walkthrough should help you understand each step of the script's execution. Enjoy!
