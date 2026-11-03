# Interactive dev/ops toolbox for the obelix cluster (SSH + tmux + Claude/Codex + MCP).
# Everything is installed at its latest version at build time; see README.md.
FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Teleport agents must stay on the same major as the cluster (server is 18.x),
# so this is the one deliberate version choice in the image.
ARG TELEPORT_MAJOR=18

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash bubblewrap btop ca-certificates curl dnsutils fd-find file fzf gettext-base \
      git gnupg htop iproute2 iputils-ping jq less lsof nano ncurses-term \
      netcat-openbsd nix-bin openssh-client openssh-server procps python3 python3-pip \
      python3-tomlkit python3-venv ripgrep rsync strace sudo tar tini tmux tree unzip vim \
      wget xz-utils yq zsh zsh-autosuggestions zsh-syntax-highlighting \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && rm -rf /var/lib/apt/lists/*

# Third-party apt repos: Node.js (NodeSource "current" line), GitHub CLI, Teleport.
# Teleport publishes LTS codenames only, so it uses the noble repo.
RUN install -d -m 0755 /etc/apt/keyrings \
  && node_line=$(curl -fsSL https://deb.nodesource.com/setup_current.x | sed -n 's/^NODE_VERSION="\(.*\)"$/\1/p') \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${node_line} nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       -o /etc/apt/keyrings/githubcli.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
  && curl -fsSL https://apt.releases.teleport.dev/gpg -o /etc/apt/keyrings/teleport.asc \
  && echo "deb [signed-by=/etc/apt/keyrings/teleport.asc] https://apt.releases.teleport.dev/ubuntu noble stable/v${TELEPORT_MAJOR}" \
       > /etc/apt/sources.list.d/teleport.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends nodejs gh teleport \
  && rm -rf /var/lib/apt/lists/*

# Kubernetes tooling and uv, straight from upstream releases.
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod 0755 /usr/local/bin/kubectl \
  && curl -fsSL "https://get.helm.sh/helm-$(curl -fsSL https://get.helm.sh/helm-latest-version)-linux-amd64.tar.gz" \
       | tar -xz -C /usr/local/bin --strip-components=1 linux-amd64/helm \
  && curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz \
       | tar -xz -C /usr/local/bin k9s \
  && curl -fsSL https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh

# Agent CLIs and the MCP servers that run as local binaries. The rest of the MCP
# servers run via uvx/npx on demand (see rootfs/etc/toolbox/mcp-servers.json).
RUN npm install -g --no-fund --no-audit \
      @anthropic-ai/claude-code \
      @openai/codex \
      @modelcontextprotocol/server-filesystem \
  && npm cache clean --force

RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /opt/oh-my-zsh

# The login user: Ubuntu's uid 1000 "ubuntu" becomes "kieeps". No password; SSH
# is key-only. /nix is a volume for single-user Nix (nix-shell -p, nix run).
RUN usermod -l kieeps -d /home/kieeps -s /bin/zsh ubuntu \
  && groupmod -n kieeps ubuntu \
  && usermod -p '*' kieeps \
  && install -d -o kieeps -g kieeps /nix /workspace

COPY rootfs/ /

RUN chmod 0755 /usr/local/bin/toolbox-*

WORKDIR /home/kieeps
EXPOSE 22
# tini reaps orphaned processes (tmux, MCP servers) that end up under PID 1.
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/toolbox-entrypoint"]
