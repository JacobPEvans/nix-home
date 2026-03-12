{
  buildPythonPackage,
  fetchPypi,
  docopt,
  flask,
  markdown,
  path-and-address,
  requests,
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "grip";
  version = "4.6.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PPbc4KoG7dZjF2kUBpr4PxncuQ86nEAScaz6cYcvjOM=";
  };

  dependencies = [
    docopt
    flask
    markdown
    path-and-address
    requests
    werkzeug
  ];

  nativeBuildInputs = [ setuptools ];

  doCheck = false;
}
