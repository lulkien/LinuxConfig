# NIXOS CONFIGURATION FOR HOME SERVER

{
  config,
  lib,
  pkgs,
  ...
}:

let
  highPrioUutils = pkgs.lib.setPrio 0 pkgs.uutils-coreutils-noprefix;
in
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

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
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
    kernelParams = [
      "ipv6.disable=1"
    ];
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.conf.all.forwarding" = true;
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
  networking = lib.mkDefault {
    hostName = "nixos";

    enableIPv6 = false;

    useNetworkd = true;
    useDHCP = true; # We gonna control each interface manually.
    usePredictableInterfaceNames = true;

    firewall.enable = true;

    wireless = {
      iwd = {
        enable = false;
        settings = {
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
    };
    services = {
      systemd-networkd-wait-online = lib.mkForce {
        serviceConfig = {
          ExecStart = [
            "" # Clear the default
            "${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --any --timeout=60"
          ];
        };
      };
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
      viAlias = true;
      vimAlias = true;
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
      enable = false;
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
      highPrioUutils
      pciutils
      usbutils

      # Networking
      bmon
      certbot
      cloudflared
      dnsutils
      lsof
      openssl
      tcpdump

      # Terminal
      kitty

      # CLI tools
      bat
      curl
      fastfetch
      fd
      fzf
      jq
      lazygit
      lsb-release
      ripgrep
      tree
      tree-sitter
      unzip
      unar
      zip
      wget

      # Utils
      transmission_4
      wl-clipboard-rs
      wl-clipboard-x11
      # docker-compose

      # Libs
      ffmpeg-headless
      libstdcxx5

      # Development
      gnumake
      rustup
      llvmPackages_19.libcxxClang
      nodejs_23
      nixfmt-rfc-style
      python312Full
      python312Packages.virtualenv
      lua51Packages.lua
      lua51Packages.luarocks
      lua51Packages.jsregexp
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # -------------------------- SERVICES --------------------------
  services = {
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
    iperf3 = {
      enable = true;
    };
    openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    rsyncd = {
      enable = true;
      socketActivated = true;
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
