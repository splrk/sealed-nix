{ ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	sealed = {
		enable = true;
		silentBoot = true;
	};
}
