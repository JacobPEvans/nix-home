{
  pkgs,
  lib,
  fetchFromGitHub,
}:

pkgs.buildGoModule rec {
  pname = "git-flow-next";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "gittower";
    repo = "git-flow-next";
    rev = "v${version}";
    hash = "sha256-lXaO1H0BuyFddpHm9P6J2gPsYjcC+xbjHlYWc4jmtVw=";
  };

  vendorHash = "sha256-AsyF7Z/XRpkBNBWULxf3rLfx0/2jCSBAbDFhESFMuPA=";

  # Integration tests require git in $PATH, which is not available in the Nix sandbox
  doCheck = false;

  meta = with lib; {
    description = "Git-flow Next - modern git-flow workflow tool";
    homepage = "https://github.com/gittower/git-flow-next";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.darwin ++ platforms.linux;
  };
}
