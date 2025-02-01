# NIXOS CONFIGURATION FOR HOME SERVER

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];


  # -------------------------- EFI BOOT --------------------------
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp = {
      cleanOnBoot = true;
    };
  };


  # -------------------------- NETWORK --------------------------
  networking = {
    hostName = "nixmini";
    networkmanager.enable = true;

    # networking.proxy.default = "http://user:password@proxy:port/";
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };


  # -------------------------- USERS --------------------------
  users = {
    users.lhkien = {
      createHome = true;
      description = "Kien H. Luu";
      extraGroups = [ "wheel" "networkmanager" "audio" "docker" ];
      home = "/home/lhkien";
      initialPassword = "ark";
      isNormalUser = true;
      shell = pkgs.fish;
    };
  };

  # -------------------------- DOCUMENTATION --------------------------
  documentation = {
    man = {
      enable = true;
    };
    info.enable = true;
  };

  # -------------------------- PROGRAMS --------------------------
  programs = {
    fish = {
      enable = true;
    };
    git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "master";
        };
        color = {
          ui = true;
        };
        core = {
          editor = "nvim";
        };
        user = {
          name = "lulkien";
          email = "kien.luuhoang.arch@outlook.com";
        };
      };
    };
    htop = {
      enable = true;
    };
    less = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    tmux = {
      enable = true;
    };
    vim = {
      enable = true;
    };
    yazi = {
      enable = true;
    };
  };


  # -------------------------- PACKAGES --------------------------
  environment = {
    systemPackages = with pkgs; [
      fastfetch
      lsb-release
      wget
      curl
      unzip
      unar
      jq
      rustup
      python3Full
      luajit
      dart-sass
      tree-sitter
      ripgrep
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };


  # -------------------------- SERVICES --------------------------
  services = {
    # autossh = {
    #   sessions = {
    #     # Put sesstion here
    #   };
    # };
    dbus = {
      enable = true;
      implementation = "broker";
    };
    openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
    rsyncd = {
      enable = true;
      socketActivated = true;
    };
    timesyncd = {
      enable = true;
      servers = [ "pool.ntp.org" ];
    };
    udev = {
      enable = true;
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    uptimed = {
      enable = true;
    };
    watchdogd = {
      enable = true;
    };
  };





  # -------------------------- MISC --------------------------
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Asia/Ho_Chi_Minh";
  };


  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };






  # -------------------------- MUST NOT MODIFY SECTION --------------------------
  # DO NOT modify anything after this line, no matter what.
  system.stateVersion = "24.11"; # Did you read the comment?

}

