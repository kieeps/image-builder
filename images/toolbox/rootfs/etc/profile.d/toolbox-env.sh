# toolbox environment: the ONE place variables enter a session.
#
# Kubernetes mounts a ConfigMap (plain settings) and a Secret (credentials) as
# directories with one file per variable. Every shell (SSH, tmux, `kubectl exec`,
# scripts) loads them here, so new keys only need adding in the cluster and
# rotated secrets show up in new shells without a restart.
#
# Sourced by /etc/zsh/zshenv and by sh/bash login shells. POSIX sh on purpose.

for _toolbox_f in /run/toolbox/config/* /run/toolbox/secrets/*; do
  [ -f "$_toolbox_f" ] || continue
  _toolbox_n=${_toolbox_f##*/}
  # Only valid variable names (skips the volume's ..data bookkeeping entries).
  case $_toolbox_n in
    '' | [0-9]* | *[!A-Za-z0-9_]*) continue ;;
  esac
  export "$_toolbox_n=$(cat "$_toolbox_f")"
done
unset _toolbox_f _toolbox_n

# Image defaults (overridable by the ConfigMap above).
: "${KUBECONFIG:=/etc/toolbox/kubeconfig}"
: "${EDITOR:=vim}"
# sshd starts sessions with a clean environment, so the image's LANG is lost.
: "${LANG:=C.UTF-8}"
# Claude Code and Codex are updated by the weekly image rebuild.
: "${DISABLE_AUTOUPDATER:=1}"
export KUBECONFIG EDITOR LANG DISABLE_AUTOUPDATER

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH" ;;
esac
export PATH
