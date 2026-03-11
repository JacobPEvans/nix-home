{
  python3Packages,
  fetchPypi,
}:

python3Packages.grip.overridePythonAttrs (_old: rec {
  version = "4.6.2";

  src = fetchPypi {
    pname = "grip";
    inherit version;
    hash = "sha256-PPbc4KoG7dZjF2kUBpr4PxncuQ86nEAScaz6cYcvjOM=";
  };

  # Remove patches - 4.6.2 already includes the Werkzeug 3 charset fix
  patches = [ ];

  # Skip tests - test helpers not in sdist, upstream tests pass
  doCheck = false;
})
