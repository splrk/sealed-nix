{ config, pkgs, lib, ... }:

let
	usersCfg = config.sealed.users;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	# TODO: Having to manually update this hash to get the right version is a little frustrating.  Can this
	#  be turned into flake that we can update with the nix cli?
	vicinae = builtins.getFlake "github:vicinaehq/vicinae?rev=eae452497165f6a679d4a0bd2c8dc8a9299ee511"; # v0.20.2

	globalDesktopEnabled = lib.any (user: user.desktop.enable) (lib.attrValues usersCfg);
	globalHyprlandEnabled = isLinux && globalDesktopEnabled && (lib.any (user: user.desktop.hyprland.enable) (lib.attrValues usersCfg));
in
{
	options.sealed.users = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.desktop.hyprland.enable = lib.mkEnableOption "Enable hyprland setup for sealed-nix";
		});
	};

	config = let
		systemConfig = {
			programs.uwsm = {
				enable = true;
				waylandCompositors.hyprland.prettyName = "Hyprland (uwsm)";
				waylandCompositors.hyprland.binPath = "${pkgs.hyprland}/bin/hyprland";
			};

			fonts.packages = with pkgs; [
				noto-fonts
				nerd-fonts.symbols-only
			];
		};

		homeManagerConfig = lib.mapAttrs (name: cfg: {
			imports = [
				vicinae.homeManagerModules.default
			];

			home.packages = [
				pkgs.networkmanagerapplet
				pkgs.hyprlock
				pkgs.hypridle
			];

			services.vicinae = {
				enable = true;
				systemd = {
					enable = true;
					autoStart = true;
					environment = {
						USE_LAYER_SHELL = 1;
					};
				};
			};

			services.hypridle = {
				enable = true;
				settings = {
					general = {
						before_sleep_cmd = "loginctl lock-session";
						after_sleep_cmd = "hyprctl dispatch dpms off";
						ignore_dbus_inhibit = false;
						lock_cmd = "pidof hyprlock || hyprlock";
					};

					listener = [
						{
							timeout = 90;
							on-timeout = "brightnessclt -s set 10";
							on-resume = "brightnessctl -r";
						}
						{
							timeout = 150;
							on-timeout = "loginctl lock-session";
						}
						{
							timeout = 210;
							on-timeout = "hyprctl dispatch dpms off";
							on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
						}
						{
							timeout = 1800;
							on-timeout = "systemctl suspend";
						}
					];
				};
			};

			# TODO: allow user to specify custom hyprland config files
			xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;

			xdg.configFile."waybar/config.jsonc".source = ./waybar-config.jsonc;
			xdg.configFile."waybar/style.css".source = ./waybar-style.css;
		}) usersCfg;
	in lib.mkIf globalHyprlandEnabled (lib.recursiveUpdate systemConfig {
			home-manager.users = lib.mapAttrs (name: value: value) homeManagerConfig;
		}
	);
}

