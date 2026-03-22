{ lib, pkgs, ... }:

let
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
	config = lib.mkIf isLinux {
		environment.systemPackages = with pkgs; [
			regreet
		];

		programs.hyprland.enable = true;

		programs.regreet.enable = true;
		environment.etc."greetd/environments".text = ''
			hyprland
			cosmic-session
		'';
	};
}
