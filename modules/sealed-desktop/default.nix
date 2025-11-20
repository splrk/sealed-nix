{ lib, config, pkgs, ... }:

let
	username = config.sealed.username;
	cfg = config.sealed.desktop;
	isLinux = pkgs.stdenv.hostPlatform == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform == "aarch64-darwin";
in
{
	import = (libs.mkMerge [
		(lib.mkIf isLinux [
			../hyprland
		])
		../sealed-nvim
	]);

	options.sealed.desktop.enabled = mkEnabledOption "Enable desktop applications and settings for sealed-nix";
	options.sealed.desktop.customPackages = lib.mkOption "Extra desktop packages to install for the host" { default = []; };

	config = mkIf cfg.enabled {
		environment.systemPackages = [
				vivaldi
		];


		home-manager.users."${username}" = { pkgs, ... }:
		{
			home.packages = with pkgs; mkMerge [
				(mkIf isLinux [
					xfce.thunar
					xfce.thunar-vcs-plugin
					xfce.thunar-archive-plugin
					swaynotificationcenter
					waybar
					dunst
				])
				(mkIf is Darwin [
					alt-tab-macos
				])
				[
					zed-editor
				]
				cfg.customPackages
			];

			programs.keepassxc = {
				enable = true;
				settings = {
					Browser.Enabled = true;

					GUI = {
						AdvancedSettings = true;
						HidePAsswords = true;
						LaunchAtStartup = true;
						ShowTrayIcon = true;
						CheckForUpdates = false;
					};

					SSHAgent.Enabled = true;
				};
			};

			programs.wezterm.enable = true;

			xdg.configFile."wezterm/wezterm.lua".source = ../../config/wezterm/wezterm.lua;
		};
	};
}
