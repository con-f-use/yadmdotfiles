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
  uv
  vault
]
