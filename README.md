# image-builder

Container images for the obelix cluster. One folder per image:

```
images/<name>/Dockerfile   →   ghcr.io/kieeps/<name>:<build number>   (+ :latest, :sha-<commit>)
```

## Images

| Image | What |
|---|---|
| [toolbox](images/toolbox) | SSH/tmux dev box with Claude Code, Codex, kubectl, Nix |
| [mcp-gateway](images/mcp-gateway) | MCP servers that need cluster credentials, over HTTP for the toolbox and Odysseus |

## Conventions

- **One folder = one image.** The folder is the build context, and the image is named after it.
  To add an image, create `images/<name>/Dockerfile`; CI picks it up automatically.
- **Unpinned contents, numbered builds.** Images install the latest version of everything at
  build time, and a weekly scheduled build refreshes them. Every build is tagged with the CI
  build number (`github.run_number`: one counter for all images, so numbers only go up but
  skip). The cluster pins that number and Renovate bumps it. `:latest` and `:sha-<commit>`
  are also pushed, for trying an image by hand.
- **Files go in `rootfs/`.** Anything an image adds to its filesystem lives under
  `images/<name>/rootfs/` at its final path and is copied in with a single `COPY rootfs/ /`.
- **No secrets or state in images.** Credentials and settings come from the cluster at runtime
  (see each image's README for what it expects). Nothing secret is ever committed here.

## CI

`.github/workflows/build.yml` builds:

- on push to `main`: only images whose folder changed
- weekly, or by hand ("Run workflow"): every image
- on pull requests: changed images, built but not pushed
