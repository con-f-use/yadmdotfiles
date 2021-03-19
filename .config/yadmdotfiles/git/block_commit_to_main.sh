#!/bin/sh
branch="$(git branch --show-current)"
if [ "${branch}" = "master" -o "${branch}" = "main" ]; then
  echo "Plese do not commit directly to master. You are on ${branch}."
  exit 1
fi

