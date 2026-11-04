# MCP gateway: the stdio MCP servers that need cluster credentials, served over
# Streamable HTTP by one mcp-proxy process for Claude Code, Codex and Odysseus.
# Every server is installed at its latest version at build time; see README.md.
FROM node:current-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# uv-managed tools and Pythons live outside any home so the runtime user can use them.
ENV UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_NO_CACHE=1

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates python3 tini \
  && rm -rf /var/lib/apt/lists/*

RUN uv tool install mcp-proxy \
  && uv tool install mcp-grafana \
  && uv tool install --python 3.13 ha-mcp \
  && uv tool install nextcloud-mcp-server \
  && uv tool install unifi-network-mcp

RUN npm install -g --no-fund --no-audit kubernetes-mcp-server @firefly-iii-mcp/local \
  && npm cache clean --force

COPY rootfs/ /
RUN chmod 0755 /usr/local/bin/mcp-gateway /usr/local/bin/signal-mcp

# The node image's uid 1000 user; no root at runtime.
USER node
WORKDIR /home/node
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/mcp-gateway"]
