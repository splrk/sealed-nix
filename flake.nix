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

	outputs = inputs@{ nixpkgs, home-manager, ... }: {

		nixosModules = {
			sealed = ./modules/sealed;
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
