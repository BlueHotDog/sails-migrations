#!/bin/bash
set -e
versions=( "0.9.8" "0.9.16" "0.10-rc8")
for version in "${versions[@]}"
do
  command="SAILS_VERSION=$version mocha test/specs"
  eval $command
done
