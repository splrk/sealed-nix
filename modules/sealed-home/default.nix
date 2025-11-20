{ pkgs, config, lib, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPatform == "aarch64-darwin";
	home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
	options.sealed.username = lib.mkOption "Username of the main system user" { default = "seal"; };
	options.sealed.stateVersion = lib.mkOption "stateVersion of the host install" { default = "25.05"; };
	options.sealed.customPackages = lib.mkOption "Extra Packages to install for the host" { default = []; };

	imports = (lib.mkMerge [
		(lib.mkIf isLinux [ import "${home-manager}/nixos" ])
		(lib.mkIf isDarwin [ import "${home-manager}/darwin" ])
	]);

	config = 
	let
		homeDir = lib.mkMerge [
			(lib.mkIf isLinux "/home/${cfg.username}")
			(lib.mkIf isDarwin "/Users/${cfg.username}")
		];
	in
	{
		home-manager.users."${cfg.username}" = { pkgs, ... }:
		{
			home.username = cfg.username;
			home.homeDirectory = homeDir;
			home.stateVersion = cfg.stateVersion;

			home.packages = with pkgs; [
					jq
					tmux
					git-lfs
					zed-editor
				] ++
				cfg.customPackages;
	
			programs.zsh.enable = true;
		};
	};
}

