{ ... }: {
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcdyTFr3H+uALgRrfbl0xvRWQQXV7BLO/oOd0Sgxr7bTN9muupo4Yf9ZCglbT8eHnRdNYmkmllWIjHH3E2izP7WSe2TNQITBMoMODiTdTPXAy3qXeLXD9Nant67d5CtkqgpOd0ObDhaupFbsNDVSJ2S7hox0Xohgg6rPmHpik4MojzmM46rTV8wqXaSzxYpaQlbUM1UurWzJPGx6smiQbVFIgckp4FnDdaAupSWC38/QyeZBhL3ZJ0h79lNUZDCxjQK/IF7PWhkZrmGVYyjVk/xEIS4QRvvlT0vIDFMcDVA0U2380JnifB83C5y+2hzMmJrdAWLtrOw0ebcZgDXPXP0/8Kk5Lqjbi9n8bx1zhLaplsCMqQyczXcw8Emo8YOWpUrgfAO607W5sJPM32V3cx0OoH7J6thcO7HHP2t+NnRofLvAwHUyZbg+3Hc8KU9TsPBTmx0xNYrGgglMYMDzi7FdOBcE7ZGrVy96PFZrmrRIY/YffcQNXE48OMVMoyRzKTgMXIHxuAZN0E4UAkMoA52kU6JfVzRAgqsUPSU+0smRLSppLO+cOXP/rrltjsIokXAS9kUMLxb5VjbzHMsYszQ2SnQfBGIApxq0l8iRRhfZ04KQmkfnluy7NGrPz77Pt/gj6oAGkXOaNj/5hORNwsk7+Acx385GqyXuZOkLuDBw== openpgp:0x3971FEB4"
  ];

  users.users.reboot = {
    isNormalUser = true;
    description = "Reboot";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcdyTFr3H+uALgRrfbl0xvRWQQXV7BLO/oOd0Sgxr7bTN9muupo4Yf9ZCglbT8eHnRdNYmkmllWIjHH3E2izP7WSe2TNQITBMoMODiTdTPXAy3qXeLXD9Nant67d5CtkqgpOd0ObDhaupFbsNDVSJ2S7hox0Xohgg6rPmHpik4MojzmM46rTV8wqXaSzxYpaQlbUM1UurWzJPGx6smiQbVFIgckp4FnDdaAupSWC38/QyeZBhL3ZJ0h79lNUZDCxjQK/IF7PWhkZrmGVYyjVk/xEIS4QRvvlT0vIDFMcDVA0U2380JnifB83C5y+2hzMmJrdAWLtrOw0ebcZgDXPXP0/8Kk5Lqjbi9n8bx1zhLaplsCMqQyczXcw8Emo8YOWpUrgfAO607W5sJPM32V3cx0OoH7J6thcO7HHP2t+NnRofLvAwHUyZbg+3Hc8KU9TsPBTmx0xNYrGgglMYMDzi7FdOBcE7ZGrVy96PFZrmrRIY/YffcQNXE48OMVMoyRzKTgMXIHxuAZN0E4UAkMoA52kU6JfVzRAgqsUPSU+0smRLSppLO+cOXP/rrltjsIokXAS9kUMLxb5VjbzHMsYszQ2SnQfBGIApxq0l8iRRhfZ04KQmkfnluy7NGrPz77Pt/gj6oAGkXOaNj/5hORNwsk7+Acx385GqyXuZOkLuDBw== openpgp:0x3971FEB4"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager = {
    users."reboot" = {
      home = {
        stateVersion = "23.11";
        username = "reboot";
        homeDirectory = "/home/reboot";
      };
    };
  };
}
