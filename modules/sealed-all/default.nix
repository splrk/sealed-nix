{ pkgs, lib, config, home-manager, ... }:

{
	imports = [
		(import ../sealed { inherit home-manager pkgs lib config; })
		../sealed-desktop
		../sealed-code
	];
}
