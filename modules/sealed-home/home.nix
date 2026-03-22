{ config, pkgs, lib, nixpkgs-unstable ... }:

let
	sealed = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
	homeDir = mkMerge [
		(mkIf isLinux "/home/${sealed.username}")
		(mkIf isDarwin "/Users/${sealed.username}")
	];
in
{
	home.username = sealed.username;
	home.homeDirectory = homeDir;
	home.stateVersion = sealed.stateVersion;

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
			jq
			tmux
			git-lfs
			zed-editor
			zsh-powerlevel10k
		]
		sealed.customPackages
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

	programs.zsh = {
		enable = true;
		dotDir = ".config/zsh";
		initContent = """
		source ${pkgs/zsh-powelevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
		""";
	};

	programs.wezterm.enable = true;

	xdg.configFile."wezterm/wezterm.lua".source = ../../config/wezterm/wezterm.lua;
}
