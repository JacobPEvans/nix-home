{ python3Packages, fetchPypi }:

python3Packages.buildPythonPackage rec {
  pname = "grip";
  version = "4.6.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PPbc4KoG7dZjF2kUBpr4PxncuQ86nEAScaz6cYcvjOM=";
  };

  dependencies = with python3Packages; [
    docopt
    flask
    markdown
    path-and-address
    requests
    werkzeug
  ];

  nativeBuildInputs = with python3Packages; [ setuptools ];

  doCheck = false;
}
