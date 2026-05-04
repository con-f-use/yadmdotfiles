{ pkgs, ... }:
with pkgs;
[
  docker-compose
  gnumake
  groovy # devpi-client
  jq
  pipenv
  poetry
  postgresql
  qda-repos
  # teams  # currently only packaged for darwin
  uv
  vault
]
