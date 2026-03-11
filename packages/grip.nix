{ python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
  pname = "grip";
  version = "4.6.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PPbc4KoG7dZjF2kUBpr4PxncuQ86nEAScaz6cYcvjOM=";
  };

  # Inherit build inputs from nixpkgs grip to avoid duplicating the dependency list
  inherit (python3Packages.grip) dependencies nativeBuildInputs;

  doCheck = false;
}
