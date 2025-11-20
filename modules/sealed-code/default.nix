{ pkgs, lib, pkgs-unstable, config, ... }:

let
	username = sealed.username;
	cfg = sealed.code;
	pkgs-unstable = import
		(builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable)
		{ config = config.nixpkgs.config };

	let vscodeOptions = {
	};
in
{
	options.sealed.code.enabled = lib.mkEnableOption "Enabled sealed-nix coding tools";
	options.sealed.code.go.enabled = lib.mkEnableOption "Enable go tools globally";
	options.sealed.code.ts.enabled = lib.mkEnableOption "Enable typescript tools globally"
	
	options.sealed.code.vsCode.enabled = lib.mkOption "Install VS Code as an editor";

	options.sealed.code.cursor.enabled = lib.mkEnableOption "Install Cursor as an editor";
	
	options.sealed.code.windsurf.enabled = lib.mkEnableOption "Install Cursor as an editor";

	options.sealed.code.zed.enabled = lib.mkEnableOption "Install the zed editor";

	config = lib.mkIf cfg.enabled {
		home-manager.users."${username}": { pkgs, ... }:
		{
			inherit pkgs-unstable;

			home.packages = (lib.mkMerge [
				(mkIf cfg.vsCode.enabled [ pkgs-unstable.vscode ])
				(mkIf cfg.cursor.enabled [ pkgs-unstable.code-cursor ])
				(mkIf cfg.windsurf.enabled [ pkgs-unstable.windsurf ])
				(mkIf cfg.zed.enabled [ pkgs-unstable.zed-editor ])
				(mkIf cfg.go.enabled [ pkgs.gopls ])
			]);
		};
	};
}
