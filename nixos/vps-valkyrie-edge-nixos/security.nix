{ ... }: {
  services = {
    fail2ban = {
      enable = true;
    };
  };

  security = {
    audit = {
      enable = true;
      backlogLimit = 8192;
      failureMode = "silent";

      # Custom audit rules monitoring sensitive actions
      rules = [
        # Monitor process executions
        "-a always,exit -F arch=b64 -S execve -k exec_log"
        # Monitor changes to user/group databases
        "-w /etc/passwd -p wa -k identity_changes"
        "-w /etc/shadow -p wa -k identity_changes"
        # Monitor changes to SSH keys
        "-w /root/.ssh -p wa -k root_ssh"
      ];
    };
  };
}
