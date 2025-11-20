{ pkgs, config, lib, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform == "x86_64-linux";
in
{
	options.sealed.slientBoot = lib.mkOption "Silent Boot" { default = false; };

	config = lib.mkIf isLinux {
		# Bootloader.
		boot.loader.systemd-boot.enable = true;
		boot.loader.efi.canTouchEfiVariables = true;

		# Use latest kernel.
		boot.kernelPackages = pkgs.linuxPackages_latest;

		boot.plymouth.enable = true;
		boot.plymouth.theme = "seal_3";
		boot.plymouth.themePackages = [
			(pkgs.adi1090x-plymouth-themes.override {
				selected_themes = [ "seal_3" ];
			})
		];

		boot.consoleLogLevel = lib.mkIf cfg.silentBoot 3;
	};
}
