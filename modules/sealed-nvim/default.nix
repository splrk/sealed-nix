{ config, ... }:

let
	username = config.sealed.username
in
{
	config = {
		home-manager.users."${username}".home = 

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.file."./.config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

}
