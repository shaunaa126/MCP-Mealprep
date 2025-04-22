# MCP-Mealprep
Where you take a bunch of containers, put little MCP snacks in them, and keep 'em cool for later.

This project takes a number of MCP servers from GitHub locations, runs them, and serves them with supergateway and optionally mcpo, and pulls them together with docker-compose to run as a stack for ML/AI resources.

## New V2 Version
Completely rebuilt thanks to [supergateway](https://github.com/supercorp-ai/supergateway) and [mcpo](https://github.com/open-webui/mcpo) projects! Can now be used for both internal and external MCP services safely and should update with python, mcpo, pip, npx, uv, and individual MCP server updates. 

The docker-compose can be considered example servers; add as many as you need from public repos following this syntax. Each custom GHCR container runs both the MCP server for local STDIO/STOUT and also exposes these servers safely on SSE protocol and optionally as an OpenAPI-compatible HTTP server for OpenWebUI. Either connect to local resources or route through a proxy like nginx, Traefik, Caddy, etc. Once exposed, you can connect to external services like OpenWebUI, n8n, Flowise, Claude, Cursor, etc.

If you only want to run locally/interally, do not add "

The GHCR container is based on debian, and should work with uv, npx, and pip installs. You should also be able to install docker mcp servers the old method, if needed. See "Depreciated Docker Process" below for more information.

### mcpo Installation
If you want to install the optional mcpo addition, add "USE_MCPO=true" to environment variables. This will instruct the startup.sh script to gather the MCP server command and environment variables and pass them to the mcpo command when ran. Please be aware this will be a duplicate server running at the same time and not connected with the original one. But it will allow for an OpenAPI-compatible endpoint that integrates with OpenWebUI and you can find more info about each server at /docs. This is not necessary, but if you want it, you can enable per server.

### startup.sh README
If you'd like more information about what exactly this bash script does once invoked in your container, please see "Startup README.md" for a comprehensive discussion of what is happening line by line. Vet it to make sure you're comfortable with running it, since it'll run in each MCP server container.

### Security scanning
## Scanning security with mcp-shield
The "startup.sh" script now runs 
```
"npx mcp-shield >> "mcp-shield.log" 2>&1
```
to run that mcp security scanner, [mcp-shield](https://github.com/riseandignite/mcp-shield) and appends to the logfile. See their documentation for more info. You can also run that command in the container at any time to see if there's an issue, for instance after an update.

## Client Connection
Once your server stack is running, you can connect your MCP client to your IP or domain and port. Or you can use mcpo commands again to connect if there's not an easy way to 

### N8N
TBD

### Flowise
TBD

### Claude, Cursor, etc
TBD

## Overview

This project is a curated collection of Model Context Protocol (MCP) servers, designed to provide a comprehensive suite of AI-powered tools and services that can be easily deployed using Docker and/or Portainer. Built upon the [official MCP Servers repository](https://github.com/modelcontextprotocol/servers), [supergateway](https://github.com/supercorp-ai/supergateway), and [OpenWebUI's mcpo repository](https://github.com/open-webui/mcpo), this project allows developers and AI enthusiasts to quickly spin up a wide range of MCP-compatible services.

## What is the Model Context Protocol?

The Model Context Protocol (MCP) is an innovative framework that enables Large Language Models (LLMs) to securely access and interact with various tools, data sources, and services. It provides a standardized way for AI agents to:

- Retrieve information from different sources
- Perform actions across various platforms
- Extend AI capabilities beyond traditional language models

## Included MCP Servers

This docker-compose collection includes servers for:

- Web Search (SearXNG and Brave)
- Everything (MCP testing)
- GitHub Interactions
- Calculator
- Slack
- Everart
- Google Maps
- Web Crawl (Fetch and Puppeteer)
- Sequential Thinking
- Postgres/Vector Retrieval (Supabase, Qwant, Pinecone, and Memory)
- And more...

## Prerequisites

- Docker
- Portainer (not necessary, but useful)
- API Tokens/Keys for specific services (optional, depends on the server)

## Installation in Portainer

### Step 1: Prepare Portainer
1. Open your Portainer environment, usually "local"
2. Navigate to "Stacks"
3. Click "Add stack"

### Step 2: Deploy the Stack
1. Name your stack (e.g., "mcp-server-stack")
2. Under "Build method", select "Upload a file" or "Web editor"
3. Upload the `docker-compose.yml` from this repository or copy and paste
4. Configure any required environment variables
   - Slack Bot Token
   - GitLab Personal Access Token
   - Google Maps API Key
   - Brave Search API Key
   - etc.
5. Click "Deploy the stack"

### Step 3: Configure Individual Servers
- Some servers require specific configuration or API tokens
- Refer to the individual server documentation in the [MCP Servers repository](https://github.com/modelcontextprotocol/servers)

## Running

### Warnings
This is a first step to running these MCP services in a containerized and easier-to-deploy process. But you'll need to do some testing and validation for soem of the environment variables and connecting to other services, especially for adding other servers. I've tested most of these personally at least running on a VPS stack, so they should be beta level functional. And V2 runs better than V1. And this runs each server with an SSE connection, and that should be secure. But your underlying system, proxy, or encryption settings might have some security flaws. This project does not vet MCP server functionality or safety, merely packages for easy server deployment and secure traffic. If you require MCP server vetting, look into [MCP Evaluator](https://github.com/JeredBlu/custom-instructions/blob/main/mcpevaluatorv3.md)

## Customization

### Adding/Removing Servers
- Simply comment out or remove the service block in the `docker-compose.yml`
- Ensure you have the necessary Dockerfile and dependencies

### Environment Variables
- Replace placeholder tokens on both environment variables and command variables with necessary settings, like your actual API keys
- Customize port mappings if needed, default is sequential

## Security Considerations
- Keep API tokens and sensitive information confidential
- Use read-only volumes where possible
- Regularly update your servers and dependencies

## Contributing
Any new MCP servers need a clean install command via npx, uv, or pip. If you have one you'd like added, please send a pull request or issue with a testing and known-working docker-compose container section 

### Adding New MCP Servers to this project
1. Ensure the server follows MCP protocol
2. Follows the above syntax, including all known environment variables and "startup.sh" command
3. Provide clear documentation, including GitHub repo for MCP server
4. Submit a pull request or issue with proposed additions

## Depreciated Docker Process
V1 MCP Mealprep used Github Dockerfiles from the individual repos, and would run them in containers via docker-compose. This worked, but could be relatively insecure and didn't allow connection with all clients. If the MCP server you want to use isn't available via npx, uv, pip, etc. and you can validate the Dockerfile is running securely doing what you want, you can feel free to continue to use this method. The server needs to have a Dockerfile in their repo, and anything that uses a "uv.lock" file seems to block installation via this method. Look at docker-compose-old.yml or this example to see how it should work:

```
version: '3.8'
services:
  mcp-server-everything: 
    build:
      context: https://github.com/modelcontextprotocol/servers.git#main
      dockerfile: src/everything/Dockerfile
    image: mcp-server:latest
    container_name: mcp-everything-server
    ports:
      - "0.0.0.0:8081:8081"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    networks:
      - mcp-network
```

## License

This project is open-source. Individual MCP servers may have their own licensing terms.

## Resources
- [Official MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Model Context Protocol Website](https://modelcontextprotocol.io)
- [MCP Evaluator](https://github.com/JeredBlu/custom-instructions/blob/main/mcpevaluatorv3.md)

## Disclaimer
This collection is community-maintained and not officially affiliated with the Model Context Protocol project, OpenWebUI, mcpo, or any other projects, implicit or implied.

---
