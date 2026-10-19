{ inputs, ... }:
let
  spaces = {
    work = "8a2c47f0-1d9e-4b36-a5c8-f70e92b4d615";
    personal = "4b1e9d72-3a56-4c80-b9f1-27e6d0a4c8b3";
    social = "3d9d2e48-5c58-4c01-bae6-114c21f228b4";
  };
  mkLockedAttrs = builtins.mapAttrs (
    _: value: {
      Value = value;
      Status = "locked";
    }
  );

  mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

  mkExtensionEntry =
    {
      id,
      pinned ? false,
    }:
    let
      base = {
        install_url = mkPluginUrl id;
        installation_mode = "force_installed";
        private_browsing = true;
      };
    in
    if pinned then base // { default_area = "navbar"; } else base;

  mkExtensionSettings = builtins.mapAttrs (
    _: entry: if builtins.isAttrs entry then entry else mkExtensionEntry { id = entry; }
  );
  homeConfig = { pkgs, ... }: {
    imports = [ inputs.zen.homeModules.beta ];
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      darwin.packageMode = "wrapped";
      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = mkLockedAttrs {
          "ui.systemUsesDarkTheme" = true;
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.warnOnClose" = false;
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
          # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
          "browser.gesture.swipe.left" = "";
          "browser.gesture.swipe.right" = "";
          "browser.tabs.hoverPreview.enabled" = true;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.topsites.contile.enabled" = false;

          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
          "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;
          "privacy.spoof_english" = 1;

          "privacy.firstparty.isolate" = true;
          "network.cookie.cookieBehavior" = 5;
          "dom.battery.enabled" = false;

          "gfx.webrender.all" = true;
          "network.http.http3.enabled" = true;
          "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0
        };
        ExtensionSettings = mkExtensionSettings {
          # Extension to get IDs of other extensions
          "queryamoid@kaply.com" = {
            install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
            private_browsing = true;
          };
          "uBlock0@raymondhill.net" = mkExtensionEntry {
            id = "ublock-origin";
            pinned = true;
          };
          "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
          "{74145f27-f039-47ce-a470-a662b129930a}" = "clearurls";
          "github-no-more@ihatereality.space" = "github-no-more";
          "github-repository-size@pranavmangal" = "gh-repo-size";
          "@searchengineadremover" = "searchengineadremover";
          "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";
          "trackmenot@mrl.nyu.edu" = "trackmenot";
          "jid1-KKzOGWgsW3Ao4Q@jetpack" = "i-dont-care-about-cookies";
          "sponsorBlocker@ajay.app" = "sponsorblock";
        };
      };
      profiles.default = {
        settings = {
          "zen.ctrlTab.show-pending-tabs" = true;
          "zen.workspaces.continue-where-left-off" = true;
          "zen.view.compact.hide-tabbar" = true;
          "zen.urlbar.behavior" = "float";
          "zen.welcome-screen.seen" = true;
          "zen.theme.use-system-colors" = false;
        };
        mods = [
          "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
          "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
          "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
        ];
        search = {
          force = true;
          default = "google";
          engines = {
            nixpkgs = {
              name = "Nixpkgs Search";
              urls = [
                {
                  template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nx" ];
            };
            home-manager = {
              name = "Home Manager Search";
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@hm" ];
            };
            github = {
              name = "GitHub Search";
              urls = [
                {
                  template = "https://github.com/search?q={searchTerms}";
                }
              ];
              definedAliases = [ "@gh" ];
            };
            youtube = {
              name = "YouTube Search";
              urls = [
                {
                  template = "https://www.youtube.com/results?search_query={searchTerms}";
                }
              ];
              definedAliases = [ "@yt" ];
            };
          };
        };
        pinsForce = true;
        pinsForceAction = "remove";
        pins = { }; # no pins
        spaces = {
          "Work" = {
            id = spaces.work;
            routes = {
              "GitHub".reference = "github.com";
              "GitHub Pages".reference = "github.io";
            };
          };
          "Social" = {
            id = spaces.social;
            routes = {
              "YouTube".reference = "youtube.com";
              "Instagram".reference = "instagram.com";
              "LinkedIn".reference = "linkedin.com";
            };
          };
        };
      };
    };
  };
in
{
  flake = {
    nixosModules.zen = { ... }: {
      home-manager.users.dilshad = homeConfig;
    };

    darwinModules.zen = { ... }: {
      home-manager.users.dilshad = homeConfig;
    };
  };
}
