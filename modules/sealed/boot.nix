{ pkgs, config, lib, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
	options.sealed.silentBoot = lib.mkOption {
		type = lib.types.bool;
		description = "Silent Boot";
		default = false;
	};

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
		boot.kernelParams = lib.mkIf cfg.silentBoot [ "quiet" "udev.log_level=3" ];
	};
}
