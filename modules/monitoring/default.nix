# Monitoring Infrastructure Module
#
# Provides deployment scripts and OTEL configuration for the monitoring stack.
# Kubernetes manifests are managed in the kubernetes-monitoring repository:
#   https://github.com/JacobPEvans/kubernetes-monitoring
#
# Usage:
#   imports = [ ./modules/monitoring ];
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.monitoring;
in
{
  options.monitoring = {
    enable = lib.mkEnableOption "Monitoring infrastructure";

    kubernetes = {
      enable = lib.mkEnableOption "Kubernetes-based monitoring stack";

      repoPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/git/kubernetes-monitoring/main";
        description = "Path to the kubernetes-monitoring repository worktree";
      };

      namespace = lib.mkOption {
        type = lib.types.str;
        default = "monitoring";
        description = "Kubernetes namespace for monitoring components";
      };

      context = lib.mkOption {
        type = lib.types.str;
        default = "orbstack";
        description = "kubectl context to use for deployments";
      };
    };

    otel = {
      enable = lib.mkEnableOption "OpenTelemetry Collector";

      endpoint = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:30317";
        description = "OTLP endpoint (defaults to gRPC NodePort for OrbStack K8s; use :30318 for http/* protocols)";
      };

      protocol = lib.mkOption {
        type = lib.types.enum [
          "grpc"
          "http/protobuf"
          "http/json"
        ];
        default = "grpc";
        description = "OTLP exporter protocol";
      };

      logPrompts = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Include user prompt content in OTEL events (privacy-sensitive).
          WARNING: This logs full conversation content including potentially sensitive data.
          Only enable in trusted environments where you control the OTEL pipeline.
        '';
      };

      logToolDetails = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Include MCP server/tool names in OTEL events";
      };

      resourceAttributes = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "OTEL resource attributes (key=value pairs). Values must not contain commas.";
      };
    };

    cribl = {
      enable = lib.mkEnableOption "Cribl Edge log shipper";

      cloudUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Cribl Cloud organization URL (e.g., https://your-org.cribl.cloud:4200)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      # Helper scripts for Kubernetes-based monitoring
      packages = lib.mkIf cfg.kubernetes.enable [
        (pkgs.writeShellScriptBin "monitoring-deploy" ''
          set -euo pipefail

          REPO_PATH="${cfg.kubernetes.repoPath}"
          export KUBE_CONTEXT="${cfg.kubernetes.context}"

          if [ ! -d "$REPO_PATH" ]; then
            echo "ERROR: kubernetes-monitoring repo not found at $REPO_PATH"
            echo "Clone it:"
            echo "  mkdir -p ~/git/kubernetes-monitoring"
            echo "  git clone git@github.com:JacobPEvans/kubernetes-monitoring.git ~/git/kubernetes-monitoring/main"
            exit 1
          fi

          echo "Deploying monitoring stack from: $REPO_PATH"
          cd "$REPO_PATH"

          # Doppler project/config stored in SOPS, deploy-doppler reads them
          if [ -f secrets.enc.yaml ]; then
            make deploy-doppler
          else
            echo "WARNING: No secrets.enc.yaml found, deploying without secrets"
            make deploy
          fi
        '')

        (pkgs.writeShellScriptBin "monitoring-status" ''
          set -euo pipefail

          CONTEXT="${cfg.kubernetes.context}"
          NAMESPACE="${cfg.kubernetes.namespace}"

          echo "=== Monitoring Stack Status ==="
          echo ""
          kubectl --context "$CONTEXT" -n "$NAMESPACE" get all
          echo ""
          echo "=== Pod Logs (last 10 lines each) ==="
          kubectl --context "$CONTEXT" -n "$NAMESPACE" get pods -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | while IFS= read -r pod; do
            echo ""
            echo "--- $pod ---"
            kubectl --context "$CONTEXT" -n "$NAMESPACE" logs "$pod" --tail=10 2>/dev/null || echo "(no logs yet)"
          done
        '')

        (pkgs.writeShellScriptBin "monitoring-logs" ''
          set -euo pipefail

          CONTEXT="${cfg.kubernetes.context}"
          NAMESPACE="${cfg.kubernetes.namespace}"

          kubectl --context "$CONTEXT" -n "$NAMESPACE" logs \
            -l app.kubernetes.io/part-of=claude-monitoring \
            --all-containers --tail=50 -f
        '')
      ];

      # Set OTEL environment variables for Claude Code
      sessionVariables = lib.mkIf cfg.otel.enable (
        {
          CLAUDE_CODE_ENABLE_TELEMETRY = "1";
          OTEL_EXPORTER_OTLP_ENDPOINT = cfg.otel.endpoint;
          OTEL_EXPORTER_OTLP_PROTOCOL = cfg.otel.protocol;
          OTEL_METRICS_EXPORTER = "otlp";
          OTEL_LOGS_EXPORTER = "otlp";
          OTEL_SERVICE_NAME = "claude-code";
          OTEL_METRICS_INCLUDE_SESSION_ID = "true";
          OTEL_METRICS_INCLUDE_VERSION = "true";
          OTEL_METRICS_INCLUDE_ACCOUNT_UUID = "true";
        }
        // lib.optionalAttrs cfg.otel.logPrompts { OTEL_LOG_USER_PROMPTS = "1"; }
        // lib.optionalAttrs cfg.otel.logToolDetails { OTEL_LOG_TOOL_DETAILS = "1"; }
        // lib.optionalAttrs (cfg.otel.resourceAttributes != { }) {
          OTEL_RESOURCE_ATTRIBUTES = lib.concatStringsSep "," (
            lib.mapAttrsToList (k: v: "${k}=${v}") cfg.otel.resourceAttributes
          );
        }
      );
    };
  };
}
