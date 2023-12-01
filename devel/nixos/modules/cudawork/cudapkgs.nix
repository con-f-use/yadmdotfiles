{ pkgs, ... }:
with pkgs; [
  poetry
  pipenv
  jq
  docker-compose
  postgresql
  groovy #devpi-client
  vault
  qda-repos
]
