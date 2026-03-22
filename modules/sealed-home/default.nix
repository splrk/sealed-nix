{ pkgs, config, lib, ... }:

let
	cfg = config.sealed;
	isLinux = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
	isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
in
{
	options.sealed.users = lib.mkOption {
		type = lib.types.attrsOf (lib.types.submodule {
			options.allowNetworkConfig = lib.mkOption {
				type = lib.types.bool;
				default = true;
				description = "Whether or not to add the user to networkmanager group";
			};

			options.administrator = lib. mkOption {
				type = lib.types.bool;
				default = false;
				description = "Whether or not the user should have admin level privileges";
			};

			options.customPackages = lib.mkOption {
				type = lib.types.listOf lib.types.anything;
				description = "Extra Packages to install for the host";
				default = [];
			};

			options.customConfig = lib.mkOption {
				type = lib.types.attrs;
				default = {};
				description = "Custom home manager configuration to merge into the sealed generated options";
			};
		});
	};

	config = 
	let
		userConfigs = lib.mapAttrs (name: userCfg:
			let
				homeDir = if isLinux then "/home/${name}"
									else if isDarwin then "/Users/${name}"
									else "";

				configDir = "${homeDir}/.config";
			in
			{
				systemUserConfig = {
					isNormalUser = true;
					extraGroups = lib.optionals (userCfg.administrator || userCfg.allowNetworkConfig) [ "networkmanager" ] ++
						(lib.optionals userCfg.administrator [ "wheel" ]);
					packages = userCfg.customPackages;
					shell = pkgs.zsh;
					home = homeDir;
				};

				homeManagerConfig = lib.recursiveUpdate {
					home.username = name;
					home.homeDirectory = homeDir;
					home.stateVersion = cfg.stateVersion;

					home.packages = with pkgs; [
						zsh-powerlevel10k
						zsh-fast-syntax-highlighting
						zsh-autosuggestions
						zsh-completions
						zsh-history-substring-search
						blueman
						] ++
						userCfg.customPackages;

					xdg.configFile."zsh/.pl10.zsh".source = ./.pl10.zsh;

					programs.zsh = {
						enable = true;
						dotDir = "${configDir}/zsh";
						initContent = ''
						source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
						source ${configDir}/zsh/.pl10.zsh
						source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
						source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
						source ${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
						export HISTORY_SUBSTRING_SEARCH_PREFIXED=1
						bindkey "$terminfo[kcuu1]" history-substring-search-up
						bindkey "$terminfo[kcud1]" history-substring-search-down

						fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
						'';
					};
				} userCfg.customConfig;
			}
		) cfg.users;

	in
	{
		programs.zsh.enable = true;

		environment.systemPackages = with pkgs; [
			jq
			tmux
			git-lfs
		];
		
		users.users = lib.mapAttrs (name: value: value.systemUserConfig) userConfigs;
		
		home-manager.users = lib.mapAttrs (name: value: value.homeManagerConfig) userConfigs;
	};
}

