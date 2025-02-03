# NIXOS CONFIGURATION FOR HOME SERVER

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # -------------------------- NIX SETTINGS --------------------------
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      keep-derivations = false;
      keep-outputs = false;
      min-free = "${toString (100 * 1024 * 1024)}"; # 100 MiB minimum free space
      max-free = "${toString (1024 * 1024 * 1024)}"; # 1 GiB maximum free space
    };
  };

  # -------------------------- EFI BOOT --------------------------
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
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
    users = {
      lhkien = {
        createHome = true;
        description = "Kien H. Luu";
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
        ];
        home = "/home/lhkien";
        initialPassword = "ark";
        isNormalUser = true;
        shell = pkgs.bash;
      };
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
    nix-ld = {
      enable = true;
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
      # Terminal
      kitty

      # CLI
      fastfetch
      lsb-release
      wget
      curl
      unzip
      unar
      jq
      ripgrep

      # Development
      llvmPackages.libcxxClang
      nodePackages_latest.nodejs
      rustup
      python3Full
      luajit
      dart-sass

      # Syntax, LSP and Formatter
      tree-sitter
      bash-language-server
      clang-tools
      lua-language-server
      nixfmt-rfc-style
      prettierd
      ruff
      shfmt
      stylua
      taplo
      typescript-language-server
      yaml-language-server
      yamlfmt
      vscode-langservers-extracted
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # -------------------------- SERVICES --------------------------
  services = {
    autossh = {
      sessions = [
        {
          name = "Linode-tunnel";
          user = "lhkien";
          monitoringPort = 0;
          extraArguments = "-N -o \"ServerAliveInterval=60\" -o \"ServerAliveCountMax=3\" -R 2222:localhost:22 lhkien@139.162.11.245";
        }
      ];
    };
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
