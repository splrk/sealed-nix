{ pkgs, lib, pkgs-unstable, config, ... }:

let
	usersCfg = config.sealed.users;
	pkgs-unstable = import
		(builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable)
		{ config = config.nixpkgs.config; };
in
{
	options.sealed.users = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.code.enabled = lib.mkEnableOption "Enabled sealed-nix coding tools";
			options.code.go.enabled = lib.mkEnableOption "Enable go tools globally";
			options.code.ts.enabled = lib.mkEnableOption "Enable typescript tools globally";
			
			options.code.vsCode.enabled = lib.mkOption "Install VS Code as an editor";

			options.code.cursor.enabled = lib.mkEnableOption "Install Cursor as an editor";
			
			options.code.windsurf.enabled = lib.mkEnableOption "Install Cursor as an editor";

			options.code.zed.enabled = lib.mkEnableOption "Install the zed editor";
		});
	};

	config = let
		homeManagerConfig = lib.mapAttrs (name: cfg: lib.mkIf cfg.code.enabled {
			home.packages = lib.mkMerge [
				(lib.mkIf cfg.code.vsCode.enabled [ pkgs-unstable.vscode ])
				(lib.mkIf cfg.code.cursor.enabled [ pkgs-unstable.code-cursor ])
				(lib.mkIf cfg.code.windsurf.enabled [ pkgs-unstable.windsurf ])
				(lib.mkIf cfg.code.zed.enabled [ pkgs-unstable.zed-editor ])
				(lib.mkIf cfg.code.go.enabled [ pkgs.gopls ])
			];
		}) usersCfg;
	in {
		home-manager.users = lib.mapAttrs (name: value: value) homeManagerConfig;
	};
}
