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
    ./system-configuration.nix
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
      experimental-features = [ "nix-command" ];
      keep-derivations = false;
      keep-outputs = false;
      min-free = "${toString (100 * 1024 * 1024)}"; # 100 MiB minimum free space
      max-free = "${toString (1024 * 1024 * 1024)}"; # 1 GiB maximum free space
    };
  };

  # -------------------------- EFI BOOT --------------------------
  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
      };
    };
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

  # -------------------------- NETWORKING --------------------------
  networking = {
    hostName = lib.mkDefault "nixos";

    useNetworkd = lib.mkDefault true;
    useDHCP = lib.mkDefault true; # We gonna control each interface manually.
    usePredictableInterfaceNames = lib.mkDefault true;

    firewall.enable = lib.mkDefault true;

    wireless = {
      iwd = {
        enable = lib.mkDefault false;
        settings = lib.mkDefault {
          Network = {
            EnableIPv6 = false;
          };
          General = {
            EnableNetworkConfiguration = true;
          };
          Settings = {
            AutoConnect = false;
          };
        };
      };
    };
  };

  # -------------------------- SYSTEMD --------------------------
  systemd = {
    network = {
      enable = true;
      # networks: system-configuration.nix
    };
  };

  # -------------------------- SYSTEM --------------------------
  system = {
    autoUpgrade = {
      enable = true;
      dates = "daily";
      operation = "switch";
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
        color = {
          ui = true;
        };
        init = {
          defaultBranch = "master";
        };
        core = {
          editor = "nvim";
        };
        pull = {
          rebase = true;
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

  # -------------------------- VIRTUALISATION --------------------------
  virtualisation = {
    docker = {
      enable = lib.mkDefault false;
      daemon = {
        settings = {
          data-root = "/var/lib/docker-data";
        };
      };
    };
  };

  # -------------------------- PACKAGES --------------------------
  environment = {
    systemPackages = with pkgs; [
      # Core
      uutils-coreutils-noprefix
      pciutils
      usbutils

      # Networking
      dnsutils
      tcpdump
      lsof
      cloudflared # Cloudflare tunnel
      openssl
      certbot

      # Terminal
      kitty

      # CLI tools
      fastfetch
      lsb-release
      wget
      curl
      zip
      unzip
      unar
      jq
      ripgrep
      fd
      tree
      tree-sitter

      # Utils
      transmission_4
      wl-clipboard-rs
      wl-clipboard-x11
      docker-compose

      # Libs
      ffmpeg-headless # Just need headless, we don't do nothing with GUI stuffs here

      # Development

      ## C/C++
      llvmPackages.clangUseLLVM
      llvmPackages.clang-tools

      ## Rust
      rustup
      # rustfmt
      # rust-analyzer

      ## Lua
      lua51Packages.lua
      lua51Packages.luarocks
      lua51Packages.jsregexp

      ## Python
      python312Full
      python312Packages.pip
      python312Packages.av
      python312Packages.python-ffmpeg

      ## Nix
      nixfmt-rfc-style

      ## Go
      go

      ## NodeJS
      nodePackages_latest.nodejs

      ## CSS compiler
      dart-sass
      # tailwindcss

      # bash-language-server
      # lua-language-server
      # prettierd
      # ruff
      # shfmt
      # stylua
      # taplo
      # typescript-language-server
      # yaml-language-server
      # yamlfmt
      # vscode-langservers-extracted
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # -------------------------- SERVICES --------------------------
  services = {
    # autossh: system-configuration.nix
    avahi = {
      enable = true;
      nssmdns4 = true;
      ipv4 = true;
      nssmdns6 = false;
      ipv6 = false;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    dbus = {
      enable = true;
      implementation = "broker";
    };
    kavita = {
      enable = true;
      tokenKeyFile = "/var/lib/kavita/tokenKey"; # Save your tokenKey here
      settings = {
        IpAddresses = "0.0.0.0,::";
        Port = 5000;
      };
    };
    openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    # openvpn: system-configuration.nix
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
