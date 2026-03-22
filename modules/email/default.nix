{ lib, config, pkgs, ... }:

let
	cfg = config.sealed.desktop.email;
	emailStrType = lib.types.strMatching "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}" // {
    description = "valid email address";
  };
in
{
	options.sealed.desktop.thunderbird.enable = lib.mkEnableOption "Enable Thunderbird desktop email client";
	options.sealed.desktop.thunderbird.accounts = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.name = lib.mkOption {
				type = lib.types.str;
				description = "Name of the account displayed in Thunderbird";
			};

			options.fullName = lib.mkOption {
				type = lib.types.str;
				description = "Full name of the person associated with the account";
			};

			options.emailAddress = lib.mkOption {
				type = emailStrType;
				description = "email address of the account";
			};

			options.imap = {
				hostname = lib.mkOption {
					type = lib.types.str;
					description = "Hostname of the email server";
				};

				port = lib.mkOption {
					type = lib.types.port;
					description = "Port number to connect to the imap server on";
				};

				username = lib.mkOption {
					type = lib.types.str;
					default = config.emailAddress;
					description = "Username to use when logging onto the email server";
				};

			};
		});

		default = {};
	};

	config = lib.mkIf cfg.enable {
		environment.systemPackages = with pkgs; [
			thunderbird
		];

		home-manager.sharedModules = [
			({ pkgs, ... }: {
				home.file.".thunderbird/".source = ./thunderbird/
			})
		];
	};
}
