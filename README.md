# MCP-Mealprep
Where you take a bunch of containers, put little snacks in them, and keep 'em cool for later.

This project takes a number of MCP servers from GitHub locations, packages them together with their referenced Dockerfiles, and pulls them together with docker-compose to run as a stack for ML/AI resources.

## Overview

This project is a curated collection of Model Context Protocol (MCP) servers, designed to provide a comprehensive suite of AI-powered tools and services that can be easily deployed using Docker and/or Portainer. Built upon the [official MCP Servers repository](https://github.com/modelcontextprotocol/servers), this collection allows developers and AI enthusiasts to quickly spin up a wide range of MCP-compatible services.

## What is the Model Context Protocol?

The Model Context Protocol (MCP) is an innovative framework that enables Large Language Models (LLMs) to securely access and interact with various tools, data sources, and services. It provides a standardized way for AI agents to:

- Retrieve information from different sources
- Perform actions across various platforms
- Extend AI capabilities beyond traditional language models

## Included MCP Servers

This docker-compose collection includes servers for:

- Web Search (SearXNG and Brave)
- File System Operations
- GitHub Interactions
- Slack Management
- Google Drive Access
- GitLab Integration
- Google Maps
- Puppeteer Web Automation
- Sequential Thinking
- AWS Knowledge Base Retrieval
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

## Customization

### Adding/Removing Servers
- Simply comment out or remove the service block in the `docker-compose.yml`
- Ensure you have the necessary Dockerfile and dependencies

### Environment Variables
- Replace placeholder tokens with your actual API keys
- Customize port mappings if needed

## Security Considerations
- Keep API tokens and sensitive information confidential
- Use read-only volumes where possible
- Regularly update your servers and dependencies

## Contributing
Any new MCP servers need to have a Dockerfile in their repo, and currently anything that uses a "uv.lock" file seems to block installation via this method. If you have a server you'd like to have included, please send a pull request. Or if you know an easy workaround for the "uv.lock" issue that involves ONLY docker-compose fixes, feel free send a pull request as well.

### Adding New MCP Servers
1. Ensure the server follows MCP protocol
2. Has a working Dockerfile
3. Provides clear documentation
4. Doesn't use a "uv.lock" file (currently)
5. Submit a pull request

## License

This project is open-source. Individual MCP servers may have their own licensing terms.

## Resources
- [Official MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Model Context Protocol Website](https://modelcontextprotocol.io)

## Disclaimer
This collection is community-maintained and not officially affiliated with the Model Context Protocol project.

---
