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

  # -------------------------- SYSTEMD --------------------------
  systemd = {
    network = {
      enable = true;

      networks = {
        "10-wired" = {
          matchConfig.Name = "enp1s0";
          networkConfig.DHCP = "yes";
          dhcpV4Config = {
            UseDNS = true;
            RouteMetric = 50;
          };
          linkConfig.RequiredForOnline = "routable";
        };

        "20-wifi" = {
          matchConfig.Name = "wlp2s0";
          networkConfig = {
            DHCP = "yes";
            IgnoreCarrierLoss = "3s";
          };
          dhcpV4Config = {
            UseDNS = true;
            RouteMetric = 100;
          };
          linkConfig.RequiredForOnline = "routable";
        };

        "30-wired" = {
          matchConfig.Name = "enp3s0";
          networkConfig.DHCP = "yes";
          dhcpV4Config = {
            UseDNS = true;
            RouteMetric = 200;
          };
          linkConfig.RequiredForOnline = "no";
        };
      };
    };
  };

  # -------------------------- NETWORK --------------------------
  networking = {
    hostName = "nixmini";

    useNetworkd = true;
    useDHCP = false; # We gonna control each interface manually.
    usePredictableInterfaceNames = true;

    wireless = {
      iwd = {
        enable = true;
        settings = {
          Network = {
            EnableIPv6 = false;
          };
          General = {
            EnableNetworkConfiguration = true;
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };

    proxy = {
      # default = "http://user:password@proxy:port/";
      noProxy = "127.0.0.1,localhost,internal.domain";
    };

    firewall = {
      enable = false;

      # Open ports in the firewall.
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };

  # -------------------------- USERS --------------------------
  # system-configuration.nix

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
    firefox = {
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
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # -------------------------- PACKAGES --------------------------
  environment = {
    systemPackages = with pkgs; [
      # Core
      pciutils
      usbutils

      # Networking
      dnsutils
      tcpdump
      lsof
      cloudflared # Cloudflare tunnel

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
      tree

      # Utils
      transmission_4
      # tigervnc
      # novnc
      # xorg.xinit
      # xterm
      podman-compose

      # Libs
      ffmpeg-headless # Just need headless, we don't do nothing with GUI stuffs here

      # Development
      llvmPackages.libcxxClang
      nodePackages_latest.nodejs
      rustup
      go
      luajit
      dart-sass

      ## Python
      python3Full
      python3Packages.pip
      python3Packages.av
      python3Packages.python-ffmpeg

      # Syntax, LSP and Formatter
      tree-sitter
      nixfmt-rfc-style
      # bash-language-server
      # clang-tools
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
      tokenKeyFile = "/var/lib/kavita/tokenKey";
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
        PasswordAuthentication = true;
      };
    };
    # openvpn: system-configuration.nix
    # pipewire = {
    #   enable = true;
    #   alsa.enable = true;
    #   alsa.support32Bit = true;
    #   pulse.enable = true;
    # };
    resolved = {
      enable = true;
      dnssec = "true";
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
    # xserver = {
    #   enable = true;
    #   desktopManager.xfce.enable = true;
    #   displayManager.lightdm.enable = true;
    # };
    watchdogd = {
      enable = true;
    };
  };

  # -------------------------- MISC --------------------------
  # security.rtkit.enable = true;
  # hardware.pulseaudio.enable = false;

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
