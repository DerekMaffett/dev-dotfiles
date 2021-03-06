# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

with lib;

let 
  setGnome = address: target: setting: "gsettings set " + address + " " + target + " " + setting + "\n";
  createKeybindSlot = i: "'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom" + (toString i) + "/'";
  setCustoms = num: setGnome 
    "org.gnome.settings-daemon.plugins.media-keys" 
    "custom-keybindings" 
    ("[" + foldl (a: b: a + ", " + b) (createKeybindSlot 0) (map createKeybindSlot (range 1 (num - 1))) + "]");
  keybind = i: {key, command}: 
    setGnome ("org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom" + i + "/") "name" ("\"" + i + "\"")
    + setGnome ("org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom" + i + "/") "command" ("\"" + command + "\"")
    + setGnome ("org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom" + i + "/") "binding" ("\"" + key + "\"");

in {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "nouveau.modeset=0 acpi_osi=Linux acpi_rev_override=1"
  ];

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    networkmanager 
    dmenu
    wget 
    vim
    google-chrome
    git
    zsh
  ];

  nixpkgs.config.allowUnfree = true;

  # nix.nixPath = [
  #   "nixos-config=/etc/nixos/configuration.nix"
  #   "/nix/var/nix/profiles/per-user/root/channels"
  # ];
  nix.binaryCaches = [ "https://cache.nixos.org/" "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];

  programs.zsh = let 
    gnomeConfigs = 
      setCustoms 3
      + keybind "0" {key = "<Alt>t"; command = "start-term";} 
      + keybind "1" {key = "<Alt>b"; command =  "start-chrome";}
      + keybind "2" {key = "<Alt>l"; command =  "start-slack";};
    gnomeScrollSettings = 
      setGnome "org.gnome.desktop.peripherals.mouse" "natural-scroll" "true"
      + setGnome "org.gnome.desktop.peripherals.touchpad" "natural-scroll" "true";
  in {
    enable = true;
    loginShellInit = ''
      export TERM="xterm-256color"
    '' + gnomeScrollSettings;
    ohMyZsh = {
      enable = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport32Bit = true;
  

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:ctrl_modifier";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.naturalScrolling = true;

  services.xserver.displayManager.sddm.enable = true;

  services.xserver.desktopManager.gnome3.enable = true;
  # services.xserver.windowManager = {
  #   xmonad = {
  #     enable = true;
  #     enableContribAndExtras = true;
  #     extraPackages = haskellPackages: [
  #       haskellPackages.xmonad-contrib
  #       haskellPackages.xmonad-extras
  #       haskellPackages.xmonad
  #     ];
  #   };
  #   default = "xmonad";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.derek = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ]; 
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
