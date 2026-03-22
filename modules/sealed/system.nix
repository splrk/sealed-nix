{ pkgs, config, lib, home-manager, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
in
{
	config = {
			services.xserver.enable = true;
	
			# Configure keymap in X11
			services.xserver.xkb = {
				layout = "us";
				variant = "";
			};

			# Enable CUPS to print documents.
			services.printing.enable = true;
			services.printing.drivers = with pkgs; [
				gutenprint
				gutenprintBin
				canon-cups-ufr2
				cnijfilter2
			];

			# Enable sound with pipewire.
			services.pulseaudio.enable = false;
			security.rtkit.enable = true;
			services.pipewire = {
				enable = true;
				alsa.enable = true;
				alsa.support32Bit = true;
				pulse.enable = true;
				# If you want to use JACK applications, uncomment this
				#jack.enable = true;

				# use the example session manager (no others are packaged yet so this is enabled by default,
				# no need to redefine it in your config for now)
				#media-session.enable = true;
			};

			# Enable networking
			networking.networkmanager.enable = true;
			
			# Set your time zone.
			time.timeZone = "America/Denver";

			# Select internationalisation properties.
			i18n.defaultLocale = "en_US.UTF-8";

			i18n.extraLocaleSettings = {
				LC_ADDRESS = "en_US.UTF-8";
				LC_IDENTIFICATION = "en_US.UTF-8";
				LC_MEASUREMENT = "en_US.UTF-8";
				LC_MONETARY = "en_US.UTF-8";
				LC_NAME = "en_US.UTF-8";
				LC_NUMERIC = "en_US.UTF-8";
				LC_PAPER = "en_US.UTF-8";
				LC_TELEPHONE = "en_US.UTF-8";
				LC_TIME = "en_US.UTF-8";
			};

			xdg.mime.enable = true;
			xdg.mime.defaultApplications = {
				"text/html" = "vivaldi-stable.desktop";
				"x-scheme-handler/http" = "vivaldi-stable.desktop";
				"x-scheme-handler/https" = "vivaldi-stable.desktop";
				"x-scheme-handler/about" = "vivaldi-stable.desktop";
				"x-scheme-handler/unknown" = "vivaldi-stable.desktop";
			};
	};
}
