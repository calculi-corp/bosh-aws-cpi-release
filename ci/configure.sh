#!/usr/bin/env bash

set -eu

fly -t bosh-ecosystem sp -p bosh-aws-cpi \
  -c ci/pipeline.yml \
  -l <( lpass show --notes "aws cpi concourse secrets")

