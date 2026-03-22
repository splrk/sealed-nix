{ pkgs, config, lib, home-manager, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
in
{

	imports = [
		./boot.nix
		./system.nix
		(import "${home-manager}/nixos")
		(import "${home-manager}/nix-darwin")
		../sealed-home
		../sealed-nvim
	];

	options.sealed.enable = lib.mkEnableOption "Enable sealed-nix desktop";
	options.sealed.stateVersion = lib.mkOption {
		description = "stateVersion of the host install";
		default = "25.05";
	};
	options.sealed.hostName = lib.mkOption {
		description = "hostname of the system";
		default = "nixos";
	};

	config = lib.mkIf cfg.enable {
		networking.hostName = cfg.hostName;
		nixpkgs.config.allowUnfree = true;

		nix.settings.experimental-features = "nix-command flakes";

		system.stateVersion = cfg.stateVersion;

		environment.systemPackages = with pkgs; [
			neovim
			git
			zsh
			git-lfs
		];
	};
}
