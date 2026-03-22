{ config, pkgs, lib, ... }:

let
	usersCfg = config.sealed.users;
in
{
	options.sealed.users = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.nvim.enable = lib.mkOption {
				type = lib.types.bool;
				default = true;
				description = "Whether to enable sealed-nix neovim configuration for this user";
			};
		});
	};

	config = let
		homeManagerConfig = lib.mapAttrs (name: cfg: lib.mkIf cfg.nvim.enable {
			xdg.configFile."nvim" = {
				source = ./lua;
				recursive = true;
			};

			xdg.configFile."nvim/pack/startup/start/onedark-nvim".source = pkgs.fetchFromGitHub {
				owner = "navarasu";
				repo = "onedark.nvim";
				rev = "v1.0.3";
				sha256 = "sha256-h7p55pZpJBhIVeWyTOkrXHabvxTFILF83PW0lp4GDrs=";
			};
		}) usersCfg;
	in {
		home-manager.users = lib.mapAttrs (name: value: value) homeManagerConfig;
	};
}
