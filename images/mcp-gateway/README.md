# mcp-gateway

The MCP servers that need cluster credentials, run in one pod and served over
Streamable HTTP by [mcp-proxy](https://github.com/sparfenyuk/mcp-proxy). Claude
Code and Codex (in the toolbox) and Odysseus all use it, so the credentials live
only here. Every server is the latest release at build time.

| Endpoint | Server |
|---|---|
| `/servers/kubernetes/mcp` | kubernetes-mcp-server, read-only, as the pod's ServiceAccount |
| `/servers/grafana/mcp` | mcp-grafana, `--disable-write` |
| `/servers/homeassistant/mcp` | ha-mcp |
| `/servers/nextcloud/mcp` | nextcloud-mcp-server |
| `/servers/unifi/mcp` | unifi-network-mcp |
| `/servers/firefly-iii/mcp` | @firefly-iii-mcp/local |
| `/servers/signal/mcp` | `signal-mcp` (in this image): `send_signal_message`, to the owner's own number only, via signal-webhook-relay |

`/status` lists the servers and their state. Every path also has an SSE variant
(`/servers/<name>/sse`).

## Where things come from

| What | Where |
|---|---|
| Server packages | `Dockerfile` |
| Server list and the variable names each one gets | `rootfs/etc/mcp-gateway/servers.json` |
| Variable values | the cluster only: ConfigMap `mcp-gateway-config` + Secret `mcp-gateway-secrets`, mounted at `/run/mcp-gateway/{config,secrets}` |

To add a server: install it in the `Dockerfile`, add it to `servers.json` with the
variable names it needs, and add those keys to the ConfigMap or ExternalSecret.

## Access

The gateway has no login of its own (Odysseus cannot send a token). Access is
limited by a NetworkPolicy to the toolbox and Odysseus pods, and mcp-proxy
rejects requests whose Host header is not the gateway's Service name.
The manifests live in the gitops repo (`clusters/obelix/workloads/util/mcp-gateway`).
