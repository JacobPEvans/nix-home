# Process cleanup hook: kill descendant processes on shell exit
#
# Uses zsh's built-in zshexit() function, called automatically when the shell
# exits (including SIGHUP from Ghostty tab close).
#
# SAFETY: Only runs in the inner shell (SCRIPT_SESSION set by session-logging.zsh).
# Only kills descendants of the current shell ($$) — cannot affect other tabs.
# Each Ghostty tab has its own shell PID with its own process subtree.
#
# Prevents orphaned MCP servers (terraform-mcp-server, context7-mcp, node)
# and Claude Code subagents when a Ghostty tab is closed mid-session.
#
# Tools used: pgrep (procps, already in systemPackages), kill (shell builtin)

zshexit() {
  # Only run in the inner shell (inside script session from session-logging.zsh)
  [[ -n "${SCRIPT_SESSION:-}" ]] || return 0

  # BFS walk of the process tree starting from the current shell
  local -a descendants=()
  local -a queue=("$$")
  local pid pgrep_out

  while [[ ${#queue[@]} -gt 0 ]]; do
    pid=${queue[1]}
    shift queue  # Remove first element and re-index safely

    pgrep_out=$(pgrep -P "$pid" 2>/dev/null) || true
    [[ -z "$pgrep_out" ]] && continue

    local -a children=("${(f)pgrep_out}")
    foreach child ("${children[@]}")
      [[ -n "$child" ]] || continue
      descendants+=("$child")
      queue+=("$child")
    end
  done

  [[ ${#descendants[@]} -eq 0 ]] && return 0

  # Graceful shutdown: SIGTERM first
  kill -TERM "${descendants[@]}" 2>/dev/null || true

  # Brief grace period for processes to exit cleanly
  sleep 1

  # SIGKILL any survivors
  local -a survivors=()
  foreach pid ("${descendants[@]}")
    kill -0 "$pid" 2>/dev/null && survivors+=("$pid")
  end

  [[ ${#survivors[@]} -gt 0 ]] && kill -KILL "${survivors[@]}" 2>/dev/null || true
}
