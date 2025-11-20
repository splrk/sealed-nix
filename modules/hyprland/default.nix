{ config, pkgs, lib, ... }:

let
	cfg = config.sealed;
	username = cfg.username;
	isLinux = pkgs.stdenv.hostPlatform == "x86_64-linux";
	walker = builtins.getFlake "github:abenz1267/walker/refs/tags/v2.8.2";
in
{
	config = lib.mkIf isLinux {
		imports = [
			walker.homeManagerModules.default
		];

		home-manager.users."${username}" = { pkgs, ... }:
		{
			programs.walker = {
				enable = true;
				runAsService = true;
			};

			wayland.windowManager.hyprland = {
				enable = true;
			};

			wayland.windowManager.hyprland.settings = {
				"$mod" = "SUPER";
				"$modShift" = "SUPER_SHIFT";

				"$terminal" = "wezterm";
				"$filemanager" = "thunar";
				"$browser" = "vivaldi";
				"$menu" = "walker";

				general = {
					"gaps_in" = 2;
					"gaps_out" = 2;
				};

				exec-once = [
					"waybar"
					"dunst"
				];

				bind = [
					"$mod, T, exec, $terminal"
					"$mod, E, exec, $filemanager"
					"$mod, SPACE, exec, $menu"
					"$mod, B, exec, $browser"
					"$mod, Q, killactive,"
					"$mod, M, exit,"
					"$mod, P, pseudo,"
					"$mod, T, togglesplit,"
					"$mod, S, togglegroup,"

					# Vim-like window switching focus
					"$mod, l, movefocus, r"
					"$mod, k, movefocus, d"
					"$mod, j, movefocus, u"
					"$mod, h, movefocus, l"

					"$mod, right, movefocus, r"
					"$mod, up, movefocus, u"
					"$mod, down, movefocus, d"
					"$mod, left, movefocus, l"

					# Swapping windows
					"$modShift, l, movewindow, r"
				];

				animations = {
					enabled = "yes, please :)";

					bezier = [
						"easeOutQuint,0.23,1,0.32,1"
						"easeInOutCubic,0.65,0.05,0.36,1"
						"linear,0,0,1,1"
						"almostLinear,0.5,0.5,0.75,1.0"
						"quick,0.15,0,1,1"
					];

					animation = [
						"global, 1, 10, default"
						"border, 1, 5.39, easeOutQuint"
						"windows, 1, 4.79, easeOutQuint"
						"windowsIn, 1, 4.1, easeOutQuint, popin 87%"
						"windowsOut, 1, 1.49, linear, popin 87%"
						"fadeIn, 1, 1.73, almostLinear"
						"fadeOut, 1, 1.46, almostLinear"
						"fade, 1, 3.03, quick"
						"layers, 1, 3.81, easeOutQuint"
						"layersIn, 1, 4, easeOutQuint, fade"
						"layersOut, 1, 1.5, linear, fade"
						"fadeLayersIn, 1, 1.79, almostLinear"
						"fadeLayersOut, 1, 1.39, almostLinear"
						"workspaces, 1, 1.94, almostLinear, fade"
						"workspacesIn, 1, 1.21, almostLinear, fade"
						"workspacesOut, 1, 1.94, almostLinear, fade"
					];
				};

				gesture = "3, horizontal, workspace";

				monitorv2 = [
					{
						# Laptop Screen
						output = "eDP-1";
						mode = "1920x1080@60";
						position = "auto";
					}
					{
						output = "HDMI-A-2";
						mode = "1920x1080@60";
						position = "auto-center-left";
					}
				];

				windowrulev2 = [
					"float, class:floating-applet"
				];
			};

			xdg.configFile."waybar/config.jsonc".text = builtins.toJSON {
				layer = "bottom";
				position = "top";
				height = 30;
				spacing = 4;

				modules-left = [
					"sway/workspaces"
					"sway/mode"
				];

				modules-center = [
				];

				modules-right = [
					"tray"
					"pulseaudio"
					"network"
					"battery"
					"clock"
				];

				network = {
					on-click = "hyprclt dispatch exec \"[float; move 100%- 40px ] nm-connection-editor\"";
				};
			};
		};
	};
}

