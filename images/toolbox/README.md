# toolbox

Interactive dev/ops box for the obelix cluster: SSH (and Teleport) into a shared
tmux session with Claude Code, Codex, kubectl/helm/k9s, uv, Node, Nix and the
MCP servers they use. Ubuntu `rolling`; everything is the latest at build time.

## Where things come from

| What | Where |
|---|---|
| Packages and tools | `Dockerfile` |
| Shell, tmux, sshd, Nix config | `rootfs/etc/` |
| Environment variables | the cluster only: ConfigMap `toolbox-config` + Secret `toolbox-secrets`, mounted as files and loaded by `rootfs/etc/profile.d/toolbox-env.sh` in every shell |
| MCP servers (Claude + Codex) | `rootfs/etc/toolbox/mcp-servers.json`, applied by `toolbox-mcp-sync` at start |
| Kubernetes access | the pod's ServiceAccount, via `rootfs/etc/toolbox/kubeconfig` |
| Personal shell tweaks | `~/.zshrc` in the persistent home (never touched by the image) |

To add a variable, add a key to the ConfigMap or the ExternalSecret; new shells pick
it up without a restart. To add an MCP server, add it to `mcp-servers.json`
(list the variable names it needs under `env`).

## Runtime contract

| Mount | Purpose |
|---|---|
| `/home/kieeps` | persistent home |
| `/var/lib/toolbox` | persistent system state: SSH host keys, Teleport identity |
| `/nix` | persistent Nix store (`nix-shell -p`, `nix run`) |
| `/run/toolbox/config` | ConfigMap, one file per variable |
| `/run/toolbox/secrets` | Secret, one file per variable |
| `/run/toolbox/teleport/auth-token` | optional: Teleport join token (first join only) |
| `/host-share`, `/host-nixos` | optional host folders (skills, extra `authorized_keys`, NixOS repo) |

SSH accepts keys only: the keys declared for `kieeps` in the NixOS repo
(`/host-nixos/users/kieeps.nix`) plus `/host-share/authorized_keys`.
Teleport starts when `TELEPORT_PROXY_SERVER` is set.

The manifests live in the gitops repo (`clusters/obelix/workloads/util/toolbox*`).
