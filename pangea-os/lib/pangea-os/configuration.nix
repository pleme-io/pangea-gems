# lib/pangea-os/configuration.nix
{...}: {
  imports = [<nixpkgs/nixos/modules/virtualisation/amazon-image.nix>];
  networking.hostName = "pleme";
  services.openssh.enable = true;
  users.users.ec2 = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = ["<your-public-key-here>"];
  };
}
