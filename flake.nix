{
	description = "Ryan's Nix Configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

#		elephant.url = "github:abenz1267/elephant/refs/tags/v2.13.2";
#		walker = {
#			url = "github:abenz1267/walker/refs/tags/v2.8.2";
#			inputs.elephant.follows = "elephant";
#		};
	};

	outputs = inputs@{ nixpkgs, home-manager, ... }: 

	let
		customModule = moduleName: ({ pkgs, config, lib, ... }: import moduleName { inherit pkgs config lib home-manager; });
		sealed = customModule ./modules/sealed/default.nix;
		sealed-desktop = customModule ./modules/sealed-desktop/default.nix;
		sealed-all = customModule ./modules/sealed-all/default.nix;
	in
	{

		nixosModules = {
			inherit sealed sealed-desktop sealed-all;
		};

		# nixosConfigurations = {
		# 	nixos = nixpkgs.lib.nixosSystem {
		# 		system = "x86_64-linux";
		# 		modules = [
		# 			./modules/sealed
		# 		#	./modules/sealed-home
		# 		#	./modules/sealed-nvim
		# 		];
		# 	};
		# };
	};
}
