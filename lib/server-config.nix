# Server-Specific Configuration Variables
#
# Shared configuration for all server hosts (non-workstations).
# Import this file in server host configurations.

{
  # ==========================================================================
  # Proxmox Server
  # ==========================================================================
  proxmox = {
    # Network hostname
    hostname = "pve";

    # Proxmox web UI port
    webUIPort = 8006;
  };

  # ==========================================================================
  # Ubuntu Server
  # ==========================================================================
  ubuntu = {
    # Network hostname (customize per-server)
    hostname = "ubuntu-server";
  };

  # ==========================================================================
  # Common Server Settings
  # ==========================================================================
  common = {
    # SSH port (standard)
    sshPort = 22;

    # Default timezone for servers
    timezone = "America/New_York";
  };
}
