{ pkgs, config, lib, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform == "aarch64-darwin";
in
{

	imports = [
			./boot.nix
			../hyprland
			../sealed-home
		#	../sealed-desktop
		#	../sealed-code
	];

	options.sealed.enable = lib.mkEnableOption "Enable sealed-nix desktop";
	options.sealed.hostName = lib.mkOption "Set the hostname" { default = "nixos"; };

	config = lib.mkIf cfg.enable {
		networking.hostName = cfg.hostName;
		nixpkgs.config.allowUnfree = true;

		environment.systemPackages = with pkgs; [
			neovim
			git
			zsh
			git-lfs
		];
	};
}
