{
  flake.darwinModules.networking =
    { ... }:
    {
      networking = {
        hostName = "macos";
        applicationFirewall.enable = false;
        computerName = "macos";
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        knownNetworkServices = [
          "Ethernet"
          "Thunderbolt Bridge"
          "Wi-Fi"
        ];
      };
    };
}
