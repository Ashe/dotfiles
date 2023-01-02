##########################################################################
## Generated using nixos-generate-config, configured for hardware usage ##
##########################################################################

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    # Load Samsung Odyssey G9 EDID to support 240hz
    kernelParams = [
      "drm.edid_firmware=DP-1:edid/samsung-g9.bin"
      "video=DP-1:e"
      "quiet"
    ];
  };

  # Add EDID for Samsung Odyssey G9 Monitor
  hardware.firmware = [(
    pkgs.runCommandNoCC "install-odyssey-g9-edid" { } ''
      mkdir -p $out/lib/firmware/edid
      cp ${./samsung-g9.bin} $out/lib/firmware/edid/samsung-g9.bin
    ''
  )];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d8b8d4ac-10dd-4ece-8653-96ff070c7fe4";
      fsType = "ext4";
    };

  fileSystems."/HD" = {
    device = "/dev/disk/by-uuid/e8a0f5c8-4a6f-4deb-a279-6c8b3eff0b1b";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/38CB-584D";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c7dfc65d-5864-4b19-ae8e-378d34507c0f"; }
    ];


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
