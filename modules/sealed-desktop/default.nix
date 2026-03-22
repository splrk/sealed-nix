{ lib, config, pkgs, home-manager, ... }:

let
	usersCfg = config.sealed.users;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
	globalDesktopEnabled = lib.any (user: user.desktop.enable) (lib.attrValues usersCfg);
in
{
	imports = [
		./greeter.nix
		../sealed-hyprland
	];

	options.sealed.users = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.desktop.enable = lib.mkEnableOption "Enable desktop applications and settings for sealed-nix";
			options.desktop.customPackages = lib.mkOption {
				description = "Extra desktop packages to install for the host";
				default = [];
			};
			options.desktop.fileSync.enable = lib.mkEnableOption "installation of file-syncing applications";

			options.desktop.fileSync.accounts = lib.mkOption {
				type = lib.types.listOf (lib.types.submodule {
					options.enable = lib.mkEnableOption "Nextcloud account";
					options.url = lib.mkOption {
						description = "URL of the nextcloud server";
						type = lib.types.str;
					};
					options.serverVersion = lib.mkOption {
						description = "Version of next cloud the servier is running";
						type = lib.types.str;
					};
					options.davUser = lib.mkOption {
						description = "Username for WebDav syncing";
						type = lib.types.str;
					};
					options.displayName = lib.mkOption {
						description = "DisplayName of the Account";
						type = lib.types.str;
					};

					options.folders = lib.mkOption {
						type = lib.types.listOf (lib.types.submodule {
							options.ignoreHiddenFiles = lib.mkOption {
								type = lib.types.bool;
							};
							options.localPath = lib.mkOption {
								type = lib.types.str;
							};
							options.targetPath = lib.mkOption {
								type = lib.types.str;
							};
						});
					};
				});
			};
		});
	};

	config = let
		systemConfig = {
			environment.systemPackages = with pkgs; [
				vivaldi
				wezterm
				kdePackages.okular
			];
		};

		homeManagerConfig = lib.mapAttrs (name: cfg: lib.mkIf cfg.desktop.enable (let
			homeDir = if isLinux then "/home/${name}"
								else if isDarwin then "/Users/${name}"
								else "";
		in
		{

			home.packages =
				(lib.optionals isLinux (with pkgs; [
					thunar
					thunar-vcs-plugin
					thunar-archive-plugin
					swaynotificationcenter
					waybar
					dunst
					networkmanager_dmenu
					nextcloud-client
					logseq
					gnome-sound-recorder
				])) ++
				(lib.optionals isDarwin [
					pkgs.alt-tab-macos
				]) ++
				[
					pkgs.zed-editor
				] ++ (lib.optionals cfg.desktop.fileSync.enable [
					pkgs.nextcloud-client
					pkgs.crudini
					pkgs.cryptomator
				])
				++ cfg.desktop.customPackages;
			
			programs.keepassxc = {
				enable = true;
				settings = {
					Browser.Enabled = true;

					GUI = {
						AdvancedSettings = true;
						HidePAsswords = true;
						LaunchAtStartup = true;
						ShowTrayIcon = true;
						CheckForUpdates = false;
					};

					SSHAgent.Enabled = true;
				};
			};

			programs.wezterm.enable = true;

			# TODO: make this customizable for each user
			xdg.configFile."wezterm/wezterm.lua".source = ../../config/wezterm/wezterm.lua;

			services.nextcloud-client = lib.mkIf cfg.desktop.fileSync.enable {
				enable = true;
				startInBackground = true;
				package = pkgs.nextcloud-client;
			};

			# xdg.userDirs = {
			# 	createDirectories = true;
			# 	extraConfig = builtins.listToAttrs (lib.map (folder: { name = "XDG_${folder.localPath}_DIR"; value = "${homeDir}/${folder.localPath}"; }) (lib.lists.flatten (lib.lists.map (folders: folders) cfg.desktop.fileSync.accounts)));
			# };

			xdg.configFile."sealed/Nextcloud/nextcloud.cfg".text = lib.mkIf cfg.desktop.fileSync.enable (lib.generators.toINI {} {
				General = {
					clientPreviousVersion = "";
					clientVersion = "4.0.4";
					confirmExternalStorage = "true";
					desktopEnterpriseChannel = "stable";
					isVfsEnabled = "false";
					launchOnSystemStartup = "true";
					monoIcons = "false";
					moveToTrash = "false";
					newBigFolderSizeLimit = "500";
					notifyExistingFoldersOverLimit = "false";
					optionalServerNotifications = "true";
					overrideLocalDir = "";
					overrideServerUrl = "";
					promptDeleteAllFiles = "false";
					serverHasValidSubscription = "true";
					showCallNotifications = "true";
					showChatNotifications = "true";
					showInExplorerNavigationPane = "false";
					showQuotaWarningNotifications = "true";
					stopSyncingExistingFoldersOverLimit = "false";
					updateChannel = "stable";
					useNewBigFolderSizeLimit = "true";
				};

				Accounts = lib.attrsets.mergeAttrsList (
					[
						{
							version = 13;
						}
					] ++ (lib.lists.imap0 (i: account: lib.attrsets.mergeAttrsList (
						[
							(let
								index = builtins.toString i;
							in
							{
								"${index}\\version" = 13;
								"${index}\\url" = account.url;
								"${index}\\serverVersion" = account.serverVersion;
								"${index}\\serverHasValidSubscription" = "true";
								"${index}\\displayName" = account.displayName;
								"${index}\\webflow_user" = account.davUser;
								"${index}\\dav_user" = account.davUser;
							})
						] ++ lib.lists.imap0 (fi: folder: (
							let
								index = builtins.toString i;
								findex = builtins.toString fi;
							in
							{
								"${index}\\Folders\\${findex}\\ignoreHiddenFiles" = folder.ignoreHiddenFiles;
								"${index}\\Folders\\${findex}\\localPath" = "${homeDir}/${folder.localPath}";
								"${index}\\Folders\\${findex}\\targetPath" = folder.targetPath;
								"${index}\\Folders\\${findex}\\version" = 2;
								"${index}\\Folders\\${findex}\\virtualFilesMode" = "off";
							}
						)) account.folders
					)) cfg.desktop.fileSync.accounts)
				);
			});
		})) usersCfg;
	in lib.mkIf globalDesktopEnabled (systemConfig// {
		home-manager.users = lib.mapAttrs (name: value: value) homeManagerConfig;
	});
}
