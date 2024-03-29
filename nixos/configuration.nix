# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pick only one of the below networking options.
  networking = {
    hostName = "nixos";
    wireless = {
        iwd.enable = true;
    };
    networkmanager = {
        enable = true;
        wifi.backend = "iwd";
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # keyMap = "us";
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    # enable = true;
    videoDrivers = [ "amdgpu" ];

    # Configure keymap in X11
    # layout = "us";
    # xkbOptions = "eurosign:e,caps:escape";

    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };

  # Vulkan configuration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ark = {
    description = "Ark";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "seat" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Must have
    git
    fish
    vim

    # For hyprland
    seatd
    xwayland
    hyprpaper
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    swaylock-effects
    eww-wayland

    # Development tools
    rustup
    nodejs_20
    gnat13
    llvmPackages_rocm.clang
    python311
    python311Packages.pip
    # python311Packages.pydbus
    python311Packages.pygobject3

    # CLI apps
    neovim
    kitty
    wofi
    dunst
    wget
    curl
    rsync
    htop
    neofetch
    wl-clipboard
    unzip
    unar
    grim
    slurp
    jq
    ffmpeg_6
    bluez
    bluez-tools

    # GUI apps
    cinnamon.nemo-with-extensions
    gnome.eog
    gnome.gnome-keyring
    gnome.seahorse
    polkit
    polkit_gnome
    blueman

    # Misc
    libsForQt5.breeze-gtk
    libsForQt5.breeze-icons
  ];

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.cargo/bin"
    ];
    EDITOR = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Hyprland enabled
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # List services that you want to enable:
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

